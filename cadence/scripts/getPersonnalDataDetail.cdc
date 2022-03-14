import TokenLendingPlace from 0x04

pub fun main(accountAddr: Address): {String:UFix64?} {

    // Get the public account object of accountAddr
    let account = getAccount(accountAddr)
    let acctlendingRef = TokenLendingPlace.borrowCollection(address: accountAddr)
                    ?? panic("No collection with that address in TokenLendingPlace")

    return {
        "supplyFlow": acctlendingRef.getmFlow() * TokenLendingPlace.getmFlowTokenPrice(),
        "supplyUSDC": acctlendingRef.getmFiatToken() * TokenLendingPlace.getmFiatTokenTokenPrice(),
        "borrowFlow": acctlendingRef.getMyBorrowingmFlow() *  TokenLendingPlace.getmFlowBorrowingTokenPrice(),
        "borrowUSDC": acctlendingRef.getMyBorrowingmFiatToken() * TokenLendingPlace.getmFiatTokenBorrowingTokenPrice()
    }
}
