import TokenLendingPlace from 0x04

pub fun main(accountAddr: Address): {String:UFix64?} {
    // Get the public account object for account 0x01
    let account = getAccount(accountAddr)
    let acct1saleRef = account.getCapability<&AnyResource{TokenLendingPlace.TokenLendingPublic}>(TokenLendingPlace.CollectionPublicPath)
        .borrow()
        ?? panic("Could not borrow acct2 nft sale reference")


    return {"supplyFlow": acct1saleRef.getmFlow()*TokenLendingPlace.getmFlowtokenPrice(), "supplyFUSD": acct1saleRef.getmFUSD()*TokenLendingPlace.getmFUSDtokenPrice(), "supplyBlt": acct1saleRef.getmBLT()*TokenLendingPlace.getmBLTtokenPrice(),
    "borrowFlow": acct1saleRef.getmyBorrowingmFlow()*TokenLendingPlace.getmFlowBorrowingtokenPrice(), "borrowFUSD": acct1saleRef.getmyBorrowingmFUSD()*TokenLendingPlace.getmFUSDBorrowingtokenPrice(), "borrowBlt": acct1saleRef.getmyBorrowingmBLT()*TokenLendingPlace.getmBLTBorrowingtokenPrice() }
}