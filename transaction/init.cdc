import FungibleToken from 0x01
import TokenLendingPlace from 0x04
import FUSD from 0x03
import BloctoToken from 0x05

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

    // It's okay if the account is already set up, yet in this case, we don't want to replace it
    if (acct.borrow<&BloctoToken.Vault>(from: BloctoToken.TokenStoragePath) == nil) {
        // Create a new Blocto token vault and put it in storage
        acct.save(<-BloctoToken.createEmptyVault(), to: BloctoToken.TokenStoragePath)

        // Create a public capability to the vault 
        // which only exposes deposit function through Receiver interface
        acct.link<&BloctoToken.Vault{FungibleToken.Receiver}>(
            BloctoToken.TokenPublicReceiverPath,
            target: BloctoToken.TokenStoragePath
        )

        // Create a public capability to the vault
        // which only exposes balance field through balance interface
        acct.link<&BloctoToken.Vault{FungibleToken.Balance}>(
            BloctoToken.TokenPublicBalancePath,
            target: BloctoToken.TokenStoragePath
        )
    } 
  }
}
 