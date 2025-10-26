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
    mapping(uint256=>VoucherDetails) public vouchers; // voucher ki id se uska detail milega 
    mapping(uint256=>address) public highestBidder;
    mapping(uint256=>uint256) public highestBid;


// Constructor
constructor () ERC721(E-Coupan NFT, E-Coupan){

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

    function transferVoucher() external {
        // to transfer ownership of coupan to another address
    }


    // ---------------------------------------------------------------------
    // 🟡 Place a bid on a voucher (Auction)
    // ---------------------------------------------------------------------

    function bidonVoucher( uint256 _voucherId) external payable {
        vouchersDetails storage v = vouchers[_voucherId];
        if(v,sellingType)
        // u can add your bid on the coupan 
        // new price of voucher = current price of voucher + bid amount
        // their would be deadline for bidding on voucher like (10 min to 1 day , 2 day anything)
        // after deadline highest bid win the voucher and gets ownership of voucher and can access it
    }
    

}