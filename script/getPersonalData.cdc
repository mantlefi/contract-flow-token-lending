import TokenLendingPlace from 0x04

pub fun main(accountAddr: Address): {String:UFix64?} {

    // Get the public account object of accountAddr
    let account = getAccount(accountAddr)
    let acctlendingRef = account.getCapability<&AnyResource{TokenLendingPlace.TokenLendingPublic}>(TokenLendingPlace.CollectionPublicPath)
        .borrow()
        ?? panic("Could not borrow accountAddr's TokenLendingPlace reference")

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
