import FlowToken from 0x02
import FungibleToken from 0x01
import TokenLendingPlace from 0x04

transaction(amount: UFix64) {

  // Temporary Vault object that holds the balance that is being transferred
  var temporaryVault: @FlowToken.Vault
  var lendingPlace: &TokenLendingPlace.TokenLendingCollection

  prepare(acct: AuthAccount) {
    if acct.borrow<&AnyResource{TokenLendingPlace.TokenLendingPublic}>(from: TokenLendingPlace.CollectionStoragePath) == nil {
        let lendingPlace <- TokenLendingPlace.createTokenLendingCollection()
        acct.save(<-lendingPlace, to: TokenLendingPlace.CollectionStoragePath)
        acct.link<&TokenLendingPlace.TokenLendingCollection{TokenLendingPlace.TokenLendingPublic}>(TokenLendingPlace.CollectionPublicPath, target: TokenLendingPlace.CollectionStoragePath)
    }

    // withdraw tokens from your vault by borrowing a reference to it
    // and calling the withdraw function with that reference
    let vaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
        ?? panic("Could not borrow a reference to the owner's FLOW vault")
      
    self.temporaryVault <- vaultRef.withdraw(amount: amount) as! @FlowToken.Vault

    self.lendingPlace = acct.borrow<&TokenLendingPlace.TokenLendingCollection>(from: TokenLendingPlace.CollectionStoragePath)
            ?? panic("Could not borrow token lending reference")
  }

  execute {
  
   
   self.lendingPlace.repayFlow(from: <-self.temporaryVault)

    log("Transfer succeeded!")
  }
}
 