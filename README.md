// 1. connect wallet 
// create voucher(coupans)  for trade => NFT ( add deadline , )(title , desc , image (ipfs), price)
// Auction=> bid on e coupans ( pool where people can bid on it )
// create voucher(coupans) to transfer ownership => to sell 
//



Entities to create coupans
  uint256 id, // coupan  ki id for uniqueness
        address creator,// creator ka address jo own karta hai
        uint256 deadline, // bid khatam karne ka time automatically
        string uri, // ipfs ka link jaha image store hai( image , ti)
        CategoryType categoryType,// konse category mai coupan hai 
        uint256 price, // konse price se coupan ka price start hoga
        SellingType sellingType ,//  creator kya karna chahte hai coupan ka (bid , sell , gift)
        uint256 redeemDeadline,  // kab tak coupan use kiya jaa sakta hai



Future scope 
Leaderboards: Top sellers / Top bidders / Trending brands.