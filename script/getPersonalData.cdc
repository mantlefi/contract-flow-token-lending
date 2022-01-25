import TokenLendingPlace from 0x04

pub fun main(accountAddr: Address): {String:UFix64?} {

    // Get the public account object for accountAddr
    let account = getAccount(accountAddr)
    let acctlendingRef = account.getCapability<&AnyResource{TokenLendingPlace.TokenLendingPublic}>(TokenLendingPlace.CollectionPublicPath)
        .borrow()
        ?? panic("Could not borrow accountAddr's TokenLendPlace reference")

    var borrowLimit = acctlendingRef.getMaxBorrowingPower()* 0.7
    var liquidationThreshold = acctlendingRef.getMaxBorrowingPower() *0.8

    return {"supplyBalance": acctlendingRef.getMaxBorrowingPower(), "borrowBalance": acctlendingRef.getBorrowingNow(), "borrowLimit": borrowLimit, "liquidationThreshold": liquidationThreshold,
    "netValue": acctlendingRef.getBorrowingPower(), "borrowUtilization": acctlendingRef.getBorrowingNow() / acctlendingRef.getMaxBorrowingPower()}
}
