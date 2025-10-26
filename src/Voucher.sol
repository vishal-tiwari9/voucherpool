//SPDX-License-Identifier:MIT
pragma solidity ^0.8.30;
// 1. connect wallet 
// create voucher(coupans)  for trade => NFT ( add deadline , )(title , desc , image (ipfs), price)
// Auction=> bid on e coupans ( pool where people can bid on it )
// create voucher(coupans) to transfer ownership => to sell 
//

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "openzepplein/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ReentrancyGuard} from "openzeppelin/contracts/security/ReentrancyGuard.sol";



contract Voucher  is Ownable , ERC721 , ERC721URIStorage, ReentrancyGuard{

  //** Errors  */
    error InsufficientCreationfee();
    error deadlineTimeError();
    error InvalidSellingType();
    error InvalidDeadlines();
    error VoucherNotForBid();
    error BiddingTimeOver();
    error BidAmountTooLow();
    error AuctionNotYetEnded();
    error AuctionAlreadyEnded();
    error VoucherNotForSale();
    error VoucherNotActive();
    error InsufficientAmountToBuy();
    error VoucherRedeemTimeOver();
    error VoucherAlreadyRedeemed();
    error NotVoucherOwner();
     

       // ---------- enums / struct ----------

   enum CategoryType{
      FOOD, 
      CLOTHING,
      CRYPTO,
      OTHER
   }
    enum SellingType{
        BID,
        SELL,
        GIFT

    }

   struct VoucherDetails{
        uint256 id;
        address creator;
        //address recipient;
        address currentOwner;

        uint256 deadline; // time for bid to end
        uint256 redeemDeadline;// time to use or redeem the voucher;
    
        string uri;
        SellingType sellingType;
        CategoryType categoryType;
        uint256 price; // base price for bid and selling price for market
        bool isRedeemed;
        bool isActive;

    }


    // Global storage 
    uint256 public nextVoucherId;
    uint256 public creationFee = 0.001 ether;
    mapping(uint256 => VoucherDetails) public vouchers; // voucher ki id se uska detail milega 
    mapping(uint256 => address) public highestBidder;
    mapping(uint256 => uint256) public highestBid;

       // withdrawal refunds for bidders (pull pattern) //@-audit-i

mapping(address => uint256) public pendingWithdrawals;

// -----------------Events-------------- //@-audit-i
event VoucherCreated(uint256 indexed id , address indexed creator ,SellingType sellingType, uint256 price);
event BidPlaced(uint256 indexed id, address indexed bidder ,uint25 amount);
event AuctionEnded(uint256 indexed id,address winner, uint256 amount);
event VoucherBought(uint256 indexed id , address buyer , uint256 amount);
event VoucherRedeemed(uint256 indexed id , address redeemer);






// -----------------Constructor--------------
constructor () ERC721("E-Coupan NFT", "ECOUPAN"){

}


   function setCreationFee(uint256 _fee) external onlyOwner{
    creationFee = _fee;

   }

  // ---------------------------------------------------------------------
    // 🔵 Create voucher for Market
    // ---------------------------------------------------------------------

    function createVoucherForSell(
        string memory _uri;
        CategoryType _categoryType;
        
        uint256 _price;
        uint256 _redeemDeadline;


    ) payable external nonReentrant {
        
                // coupans ka title , desc , image(ipfs) , price , deadline for bid , dealine for redeem (to use coupan)...etc etc


         if(msg.value < creationFee){
            revert InsufficientCreationfee();
        }
        if(_deadline >= block.timestamp){
            revert deadlineTimeError();
        }
        if(_sellingType !=SellingType.SELL){revert InvalidSellingType();}

        if(_deadline <= _redeemDeadline){revert InvalidDeadlines();}

        uint256 nextId = ++nextVoucherId;
        vouchers[nextId] = VoucherDetails({
            id:nextId,
            creator:msg.sender,
            currentOwner:msg.sender,
            deadline:(0),
            redeemDeadline:_redeemDeadline,
            uri: _uri,
            sellingType:SellingType.SELL,
            categoryType:_categoryType,
            price:_price,
            isRedeemed:false,
            isActive:true,

    });
    _safeMint(msg.sender,nextId);
    _setTokenURI(nextId,_uri);

 emit VoucherCreated(nextId,msg.sender,SellingType.SELL,_price);

    }
         // ---------------------------------------------------------------------
    // 🔵 Create voucher for auction
    // ---------------------------------------------------------------------

    function createVoucherforBid(
        string memory _uri,
        CategoryType _categoryType,
        uint256 _basePrice,
        
        uint256 _deadline,
        uint256 _redeemDeadline,


    ) payable external  nonReentrant{
       // coupans ka title , desc , image(ipfs) , price , deadline for bid , dealine for redeem (to use coupan)...etc etc
    // To add coupans into open market place where any address can bid on  it 
        if(_deadline>=block.timestamp){
            revert deadlineTimeError();
        }

        if(msg.value<creationFee){
            revert InsufficientCreationfee();
        }
                if(_deadline<=_redeemDeadline){revert InvalidDeadlines();}

      if (_basePrice == 0) revert InvalidSellingType();
      if (_redeemDeadline <= block.timestamp) revert InvalidDeadline();

    uint256 nextId = ++nextVoucherId;
    vouchers[nextId] = VoucherDetails({
        id: nextId,
        creator:msg.sender,
        deadline:_deadline,
        redeemDealine:_redeemDeadline,
        uri:_uri,
        SellingType::_SellingType.BID,
        CategoryType:_categoryType,
        price:_basePrice,
        isRedeemed:false,
        isActive:true,

    });
    _safeMint(msg,sender,nextId);
    _setTokenURI(nextId,_uri);


emit VoucherCreated(nextId,msg.sender,SellingType.BID,_basePrice);

    }

     // ---------- gift ----------
    function giftVoucher(uint256 _voucherId, address _to) external nonReentrant {
        if (ownerOf(_voucherId) != msg.sender) revert NotOwner();
        VoucherDetails storage v = vouchers[_voucherId];

        _transfer(msg.sender, _to, _voucherId);
        v.currentOwner = _to;
        v.sellingType = SellingType.GIFT;
    }


    // function giftVoucher() external payable onlyOwner{
    //     // to gift voucher to any address


    // }




    // ---------------------------------------------------------------------
    // 🟡 Place a bid on a voucher (Auction)
    // ---------------------------------------------------------------------

    function bidonVoucher( uint256 _voucherId) external payable {

// u can add your bid on the coupan 
        // new price of voucher = current price of voucher + bid amount
        // their would be deadline for bidding on voucher like (10 min to 1 day , 2 day anything)
        // after deadline highest bid win the voucher and gets ownership of voucher and can access it

        VoucherDetails storage v = vouchers[_voucherId];
        if(v.sellingType == SelllingType.SELL){revert VoucherNotForBid();}
        if(block.timestamp>=v.deadline)revert BiddingTimeOver();
        if(msg.value<v.price && msg.value<=highestBid[_voucherId]){ revert BidAmountTooLow();}
        if (!v.isActive || v.sellingType != SellingType.BID) revert VoucherNotForBid();
        if(highestBid[_voucherId]>minRequired)minRequired=highestBid[_voucherId];
        if(msg.value<=minRequired) revert BidTooLow();

        uint256 minRequired = v.price;

 // credit previous highest bidder to pendingWithdrawals (pull)
if(highestBid[_voucherId]>0){
    pendingWithdrawals[highestBidder[_voucherId]]+=highestBid[_voucherId];
}



        // // Refund the previous highest bidder 
        // if(highestBidder[_voucherId]!=address(0)){
        //     payable(highestBidder[_voucherId]).transfer(highestBid[_voucherId]);
        // }

highestBid[_voucherId]=msg.value;
highestBidder[_voucherId]=msg.sender;

emit BidPlaced(_voucherId,msg.sender,msg.value);
        
    }



    // Bidders using it to withdraw Funds // @-audit-i
     function withdrawPending() external nonReentrant {
        uint256 amount = pendingWithdrawals[msg.sender];
       // require(amount > 0, "No funds");
       if(amount<=0{revert NoFundsToWithdraw();})
        pendingWithdrawals[msg.sender] = 0;
        (bool ok, ) = payable(msg.sender).call{value: amount}("");
        // require(ok, "Withdraw failed");
        if(!ok){revert WithdrawFailed();}
    }


     // ---------------------------------------------------------------------
    // 🔴 End auction
    // ---------------------------------------------------------------------

    function endAuction(uint256 _voucherId) external{
        // to end Auction and transfer ownership to highest bidder
        VoucherDetails storage v = vouchers[_voucher];
        if(block.timestamp<v.deadline)revert AuctionNotYetEnded();
        if (!v.isActive || v.sellingType != SellingType.BID) revert AuctionNotActive();


      

        // if(highestBidder[_voucherId]!address(0)){
        //     payable(v.currentOwner).transfer(highestBid[_voucherId]);
        //     v.currentOwner=highestBidder[_voucherid];
        //     _transfer(v.currentOwner,highestBidder[_voucherId],_voucherId);
  
//@-audit-i
        v.isActive = false;

        address winner = highestBidder[_voucherId];
        uint256 amount = highestBid[_voucherId];

         if (winner != address(0) && amount > 0) {
            // transfer funds to current owner (seller)
            (bool sent, ) = payable(v.currentOwner).call{value: amount}("");
            require(sent, "Payment to seller failed");

            // transfer token ownership
            _transfer(v.currentOwner, winner, _voucherId);
            v.currentOwner = winner;

            emit AuctionEnded(_voucherId, winner, amount);
        } else {
            // no bids -> auction ended with no sale; owner retains NFT
            emit AuctionEnded(_voucherId, address(0), 0);
        }

        // clear highestBid data to save gas/storage hygiene
        highestBid[_voucherId] = 0;
        highestBidder[_voucherId] = address(0);
    }

            // agar _transfer(v.currentOwner,creator,voucherId); likhenge to ownership wapis creator ko chala jayega
            // sirf owner hi nahi jo last bnda hai bid karne wala woh bhi ownership transfer kar ske 

        }

    }
   // ---------------------------------------------------------------------
    // 🟢 Buy voucher directly
    // ---------------------------------------------------------------------


    function buyVoucherDirect() external payable{
        // to buy voucher directly from marketplace
        VoucherDetails storage v = vouchers[_voucherId];
        if(v.sellingType!=SellingType.SELL){revert VoucherNotForSale();}
        if(v.isActive==false) {revert VoucherNotActive();}
        if(msg.value<v.price){revert InsufficientAmountToBuy();}

        v.isActive=false;
        // payable(v.currentOwner).transfer(msg.value);
        // v.currentOwner=msg.sender;

        (bool sent,) = payable(v.currentOwner).call{value:msg.value}("");
        if(!sent){revert PaymentToSellerFailed();}

        _transfer(v.currentOwner,msg.sender,_voucherId);
        v.currentOwner=msg.sender;


        emit VoucherBought(_voucherId,msg.sender,msg.value);

    }



      // ---------------------------------------------------------------------
    // ✅ Redeem voucher
    // ---------------------------------------------------------------------

    function redeemVoucher(uint256 _voucherId)external nonReentrant{
        // to redeem or use the voucher by owner
        VoucherDetails storage v = vouchers[_voucherId];
        if(block.timestamp>v.redeemDeadline){revert VoucherRedeemTimeOver();}
        if(v.isRedeemed==true){revert VoucherAlreadyRedeemed();}
        if(ownerOf(_voucherId)!=msg.sender){revert NotVoucherOwner();}

        v.isRedeemed=true;

        emit VoucherRedeemed(_voucherId,msg.sender);
    }

    
    // ---------------------------------------------------------------------
    // 💰 Withdraw platform fees  (platform that is collected on creation of Voucher)
    // ---------------------------------------------------------------------

    function withDrawFees() external onlyOwner{
        uint256 amount =address(this).balance;
        if(amount==0) {revert NoFeesToWithdraw();}

        payable(owner()).transfer(amount);

    }


    // View Helpers
    function getVoucher(uint256 id) external view returns(VoucherDetails memory){
        return vouchers[id];
    }

    // fallback  / receive to accept incoming ETh (should be minimal )
    receive external payable{}


    

}