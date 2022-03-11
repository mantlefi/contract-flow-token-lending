import TokenLendingPlace from 0x04

pub fun main(accountAddr: Address): {String:UFix64?} {
    
    // Get the public account object of accountAddr
    let account = getAccount(accountAddr)
    let acctlendingRef = TokenLendingPlace.borrowCollection(address: accountAddr)
                    ?? panic("No collection with that address in TokenLendingPlace")

    return {
        "supplyFlow": acctlendingRef.getmFlow() * TokenLendingPlace.getmFlowTokenPrice(),
        "supplyFUSD": acctlendingRef.getmFUSD() * TokenLendingPlace.getmFUSDTokenPrice(),
        "borrowFlow": acctlendingRef.getMyBorrowingmFlow() *  TokenLendingPlace.getmFlowBorrowingTokenPrice(),
        "borrowFUSD": acctlendingRef.getMyBorrowingmFUSD() * TokenLendingPlace.getmFUSDBorrowingTokenPrice()
    }
}