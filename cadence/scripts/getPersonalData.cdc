import TokenLendingPlace from 0x04

pub fun main(accountAddr: Address): {String:UFix64?} {

    // Get the public account object of accountAddr
    let account = getAccount(accountAddr)
    let acctlendingRef = TokenLendingPlace.borrowCollection(address: accountAddr)
                    ?? panic("No collection with that address in TokenLendingPlace")

    var borrowLimit = acctlendingRef.getMyTotalsupply()* TokenLendingPlace.loanToValueRatio
    var liquidationThreshold = acctlendingRef.getMyTotalsupply() * TokenLendingPlace.optimalUtilizationRate

    return {
        "supplyBalance": acctlendingRef.getMyTotalsupply(),
        "borrowBalance": acctlendingRef.getMyTotalborrow(),
        "borrowLimit": borrowLimit,
        "liquidationThreshold": liquidationThreshold,
        "netValue": acctlendingRef.getNetValue(),
        "borrowUtilization": acctlendingRef.getMyTotalborrow() / borrowLimit
    }
}
