import FungibleToken from 0xee82856bf20e2aa6
import TokenLendingPlace from 0xf8d6e0586b0a20c7
import FUSD from 0xf8d6e0586b0a20c7

// A template of transaction which could send tokens to other accounts with a vault by anyone
transaction() {
  prepare(acct: AuthAccount) {
    if acct.borrow<&AnyResource{TokenLendingPlace.TokenLendingPublic}>(from: TokenLendingPlace.CollectionStoragePath) == nil {
        let lendingPlace <- TokenLendingPlace.createTokenLendingCollection()
        acct.save(<-lendingPlace, to: TokenLendingPlace.CollectionStoragePath)
        acct.link<&TokenLendingPlace.TokenLendingCollection{TokenLendingPlace.TokenLendingPublic}>(TokenLendingPlace.CollectionPublicPath, target: TokenLendingPlace.CollectionStoragePath)
    }
    if (acct.borrow<&FUSD.Vault>(from: /storage/fusdVault) == nil) {
            
        // Create a new FUSD vault and put it in storage
        acct.save(<-FUSD.createEmptyVault(), to: /storage/fusdVault)

        // Create a public capability to the vault 
        // which only exposes deposit function through receiver interface
        acct.link<&FUSD.Vault{FungibleToken.Receiver}>(
            /public/fusdReceiver,
            target: /storage/fusdVault
        )

        // Create a public capability to the vault which only exposes
        // balance field through balance interface
        acct.link<&FUSD.Vault{FungibleToken.Balance}>(
            /public/fusdBalance,
            target: /storage/fusdVault
        )
    }

  }
}
 