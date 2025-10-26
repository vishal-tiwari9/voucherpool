//SPDX-License-Identifier:MIT
pragma solidity ^0.8.30;
// 1. connect wallet 
// create voucher(coupans)  for trade => NFT ( add deadline , )(title , desc , image (ipfs), price)
// Auction=> bid on e coupans ( pool where people can bid on it )
// create voucher(coupans) to transfer ownership => to sell 
//

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "openzepplein/contracts/token/ERC721/ERC721.sol";


contract Voucher  is Ownable , ERC721{


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
        address recipient;
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
    mapping(uint256=>VoucherDetails) public vouchers; // voucher ki id se uska detail milega 
    mapping(uint256=>address) public highestBidder;
    mapping(uint256=>uint256) public highestBid;


// Constructor
constructor () ERC721(E-Coupan NFT, E-Coupan){

}


   function setCreationFee(uint256 _fee) external onlyOwner{
    creationFee = _fee;

   }

  // ---------------------------------------------------------------------
    // 🔵 Create voucher for Market
    // ---------------------------------------------------------------------

    function createVoucherforSell(
        string memory _uri;
        CategoryType _categoryType;
        SellingType _sellingType;
        uint256 _price;
        uint256 _redeemDeadline;


    ) payable external {
        
                // coupans ka title , desc , image(ipfs) , price , deadline for bid , dealine for redeem (to use coupan)...etc etc


         if(msg.value<creationFee){
            revert InsufficientCreationfee();
        }
        if(_deadline>=block.timestamp){
            revert deadlineTimeError();
        }
        if(_sellingType!=SellingType.SELL){revert InvalidSellingType();}

        if(_deadline<=_redeemDeadline){revert InvalidDeadlines();}

        uint256 nextId = ++nextVoucherId;
        vouchers[nextId] = VoucherDetails({
            id:newId,
            creator:msg.sender,
            dealine:(0),
            redeemDeadline:_redeemDeadline,
            uri: _uri,
            SellingType:_sellingType,
            CategoryType:_categoryType,
            price:_price,
            isRedeemed:false,
            isActive:true,

    });
    _safeMint(msg.sender,nextId);
    _setTokenURI(nextId,_uri);



    }
         // ---------------------------------------------------------------------
    // 🔵 Create voucher for auction
    // ---------------------------------------------------------------------

    function createVoucherforBid(
        string memory _uri,
        CategoryType _categoryType,
        uint256 _basePrice,
        SellingType _sellingType,
        uint256 _deadline,
        uint256 _redeemDeadline,


    ) payable external {
       // coupans ka title , desc , image(ipfs) , price , deadline for bid , dealine for redeem (to use coupan)...etc etc
    // To add coupans into open market place where any address can bid on  it 
        if(_deadline>=block.timestamp){
            revert deadlineTimeError();
        }

        if(msg.value<creationFee){
            revert InsufficientCreationfee();
        }
                if(_deadline<=_redeemDeadline){revert InvalidDeadlines();}

 
    uint256 nextId= ++nextVoucherId;
    vouchers[nextId]=VoucherDetails({
        id:nextId,
        creator:msg.sender,
        deadline:_dealine,
        redeemDealine:_redeemDeadline,
        uri:_uri,
        SellingType::_sellingType.BID,
        CategoryType:_categoryType,
        price:_basePrice,
        isRedeemed:false,
        isActive:true,

    });
    _safeMint(msg,sender,nextId);
    _setTokenURI(nextId,_uri);


    }

    

    function giftVoucher() external payable onlyOwner{
        // to gift voucher to any address


    }


    // ---------------------------------------------------------------------
    // 🟡 Place a bid on a voucher (Auction)
    // ---------------------------------------------------------------------

    function bidonVoucher( uint256 _voucherId) external payable {

// u can add your bid on the coupan 
        // new price of voucher = current price of voucher + bid amount
        // their would be deadline for bidding on voucher like (10 min to 1 day , 2 day anything)
        // after deadline highest bid win the voucher and gets ownership of voucher and can access it

        vouchersDetails storage v = vouchers[_voucherId];
        if(v.sellingType == SelllingType.SELL){revert VoucherNotForBid();}
        if(block.timestamp>=v.deadline)revert BiddingTimeOver();
        if(msg.value<v.price && msg.value<=highestBid[_voucherId]){ revert BidAmountTooLow();}
        



        // Refund the previous highest bidder 
        if(highestBidder[_voucherId]!=address(0)){
            payable(highestBidder[_voucherId]).transfer(highestBid[_voucherId]);
        }

highestBid[_voucherId]=msg.value;
highestBidder[_voucherId]=msg.sender;
        
    }


     // ---------------------------------------------------------------------
    // 🔴 End auction
    // ---------------------------------------------------------------------

    function endAuction(uint256 _voucherId) external{
        // to end Auction and transfer ownership to highest bidder
        VoucherDetails storage v = vouchers[_voucher];
        if(block.timestamp<v.deadline)revert AuctionNotYetEnded();
        if(v.isActive==false)revert AuctionAlreadyEnded();


        v.isActive=false;

        if(highestBidder[_voucherId]!address(0)){
            payable(v.currentOwner).transfer(highestBid[_voucherId]);
            v.currentOwner=highestBidder[_voucherid];
            _transfer(v.currentOwner,highestBidder[_voucherId],_voucherId);

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
        payable(v.currentOwner).transfer(msg.value);
        v.currentOwner=msg.sender;

    }



      // ---------------------------------------------------------------------
    // ✅ Redeem voucher
    // ---------------------------------------------------------------------

    function redeemVoucher(uint256 _voucherId)external{
        // to redeem or use the voucher by owner
        VoucherDetails storage v = vouchers[_voucherId];
        if(block.timestamp>v.redeemDeadline){revert VoucherRedeemTimeOver();}
        if(v.isRedeemed==true){revert VoucherAlreadyRedeemed();}
        if(ownerOf(_voucherId)!=msg.sender){revert NotVoucherOwner();}

        v.isRedeemed=true;
    }

    
    // ---------------------------------------------------------------------
    // 💰 Withdraw platform fees
    // ---------------------------------------------------------------------

    function withDrawFees() external onlyOwner{
        uint256 amount =address(this).balance;
        payable(owner()).transfer(amount);
        
    }
    

}