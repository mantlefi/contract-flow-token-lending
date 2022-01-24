import FUSD from 0x03
import FungibleToken from 0x01
import TokenLendPlace from 0x04


// This transaction is a template for a transaction that
// could be used by anyone to send tokens to another account
// that owns a Vault
transaction(amount: UFix64) {


  // Temporary Vault object that holds the balance that is being transferred
  var temporaryVault: @FUSD.Vault
  var lendingPlace: &TokenLendPlace.TokenLandCollection

  prepare(acct: AuthAccount) {
   if acct.borrow<&AnyResource{TokenLendPlace.TokenLandPublic}>(from: /storage/TokenLendPlace) == nil {
            let lendingPlace <- TokenLendPlace.createTokenLandCollection()
            acct.save(<-lendingPlace, to: /storage/TokenLendPlace)
            acct.link<&TokenLendPlace.TokenLandCollection{TokenLendPlace.TokenLandPublic}>(/public/TokenLendPlace, target: /storage/TokenLendPlace)
        }
    // withdraw tokens from your vault by borrowing a reference to it
    // and calling the withdraw function with that reference
    let vaultRef = acct.borrow<&FUSD.Vault>(from: /storage/FUSDVault)
        ?? panic("Could not borrow a reference to the owner's vault")
      
    self.temporaryVault <- vaultRef.withdraw(amount: amount) as! @FUSD.Vault
    self.lendingPlace = acct.borrow<&TokenLendPlace.TokenLandCollection>(from: /storage/TokenLendPlace)
            ?? panic("Could not borrow owner's vault reference2")
  }

  execute {
  
   self.lendingPlace.addLiquidity(from: <-self.temporaryVault)

    log("Transfer succeeded!")
  }
}
 