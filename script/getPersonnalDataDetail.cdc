import TokenLendingPlace from 0x04

pub fun main(accountAddr: Address): {String:UFix64?} {
    // Get the public account object for account 0x01
    let account = getAccount(accountAddr)
    let acct1saleRef = account.getCapability<&AnyResource{TokenLendingPlace.TokenLendingPublic}>(TokenLendingPlace.CollectionPublicPath)
        .borrow()
        ?? panic("Could not borrow acct2 nft sale reference")


    return {"supplyFlow": acct1saleRef.getmFlow(), "supplyFUSD": acct1saleRef.getmFUSD(), "supplyBlt": acct1saleRef.getmBLT(),
    "borrowFlow": acct1saleRef.getmyBorrowingmFlow(), "borrowFUSD": acct1saleRef.getmyBorrowingmFUSD(), "borrowBlt": acct1saleRef.getmyBorrowingmBLT() }
}