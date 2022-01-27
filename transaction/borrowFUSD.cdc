import FUSD from 0x03
import FungibleToken from 0x01
import TokenLendingPlace from 0x04

transaction(amount: UFix64) {

  // Temporary Vault object that holds the balance that is being transferred
  var vaultRef: &FUSD.Vault
  var lendingPlace: &TokenLendingPlace.TokenLendingCollection

  prepare(acct: AuthAccount) {
    if acct.borrow<&AnyResource{TokenLendingPlace.TokenLendingPublic}>(from: TokenLendingPlace.CollectionStoragePath) == nil {
        let lendingPlace <- TokenLendingPlace.createTokenLendingCollection()
        acct.save(<-lendingPlace, to: TokenLendingPlace.CollectionStoragePath)
        acct.link<&TokenLendingPlace.TokenLendingCollection{TokenLendingPlace.TokenLendingPublic}>(TokenLendingPlace.CollectionPublicPath, target: TokenLendingPlace.CollectionStoragePath)
    }

    // withdraw tokens from your vault by borrowing a reference to it
    // and calling the withdraw function with that reference
    self.vaultRef = acct.borrow<&FUSD.Vault>(from: /storage/FUSDVault)
        ?? panic("Could not borrow a reference to the owner's FUSD vault")
      
    self.lendingPlace = acct.borrow<&TokenLendingPlace.TokenLendingCollection>(from: TokenLendingPlace.CollectionStoragePath)
            ?? panic("Could not borrow lending place reference")
  }

  execute {
    var vault <- self.lendingPlace.borrowFUSD(_amount: amount)

     self.vaultRef.deposit(from: <-vault)

    log("Borrow succeeded!")
  }
}
 