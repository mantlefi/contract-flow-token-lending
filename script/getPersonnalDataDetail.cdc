import TokenLendingPlace from 0x04

pub fun main(accountAddr: Address): {String:UFix64?} {
    
    // Get the public account object of accountAddr
    let account = getAccount(accountAddr)
    let acctlendingRef = account.getCapability<&AnyResource{TokenLendingPlace.TokenLendingPublic}>(TokenLendingPlace.CollectionPublicPath)
        .borrow()
        ?? panic("Could not borrow accountAddr's TokenLendingPlace reference")

    return {
        "supplyFlow": acctlendingRef.getmFlow() * TokenLendingPlace.getmFlowTokenPrice(),
        "supplyFUSD": acctlendingRef.getmFUSD() * TokenLendingPlace.getmFUSDTokenPrice(),
        "supplyBlt": acctlendingRef.getmBLT() * TokenLendingPlace.getmBLTTokenPrice(),
        "borrowFlow": acctlendingRef.getMyBorrowingmFlow() *  TokenLendingPlace.getmFlowBorrowingTokenPrice(),
        "borrowFUSD": acctlendingRef.getMyBorrowingmFUSD() * TokenLendingPlace.getmFUSDBorrowingTokenPrice(),
        "borrowBlt": acctlendingRef.getMyBorrowingmBLT() * TokenLendingPlace.getmBLTBorrowingTokenPrice()
    }
}