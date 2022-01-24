import TokenLendPlace from 0x04

pub fun main(accountAddr: Address): {String:UFix64?} {
    // Get the public account object for account 0x01
    let account1 = getAccount(accountAddr)
let acct1saleRef = account1.getCapability<&AnyResource{TokenLendPlace.TokenLandPublic}>(/public/TokenLendPlace)
        .borrow()
        ?? panic("Could not borrow acct2 nft sale reference")
    var borrowLimit = acct1saleRef.getMaxBorrowingPower()* 0.7
    var liquidationThreshold = acct1saleRef.getMaxBorrowingPower() *0.8

    return {"supplyBalance": acct1saleRef.getMaxBorrowingPower(), "borrowBalance": acct1saleRef.getBorrowingNow(), "borrowLimit": borrowLimit, "liquidationThreshold":liquidationThreshold,
    "netValue": acct1saleRef.getBorrowingPower(), "borrowUtilization": acct1saleRef.getBorrowingNow()/acct1saleRef.getMaxBorrowingPower()}
}