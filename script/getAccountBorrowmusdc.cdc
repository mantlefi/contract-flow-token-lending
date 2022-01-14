import TokenLendPlace from 0x04

pub fun main(accountAddr: Address) {
    // Get the public account object for account 0x01
    let account1 = getAccount(accountAddr)
let acct1saleRef = account1.getCapability<&AnyResource{TokenLendPlace.TokenLandPublic}>(/public/TokenLendPlace)
        .borrow()
        ?? panic("Could not borrow acct2 nft sale reference")

    log(acct1saleRef.getmyBorrowingmUSDC())
}