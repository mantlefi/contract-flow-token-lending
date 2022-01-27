import TokenLendingPlace from 0x04

pub fun main(accountAddr: Address): {String:UFix64?} {
    
    // Get the public account object for accountAddr
    let account = getAccount(accountAddr)
    let acctlendingRef = account.getCapability<&AnyResource{TokenLendingPlace.TokenLendingPublic}>(TokenLendingPlace.CollectionPublicPath)
        .borrow()
        ?? panic("Could not borrow acct2 nft sale reference")

    return {"supplyFlow": acctlendingRef.getmFlow(), "supplyFUSD": acctlendingRef.getmFUSD(), "supplyBlt": acctlendingRef.getmBLT(),
    "borrowFlow": acctlendingRef.getMyBorrowingmFlow(), "borrowFUSD": acctlendingRef.getMyBorrowingmFUSD(), "borrowBlt": acctlendingRef.getMyBorrowingmBLT() }
}