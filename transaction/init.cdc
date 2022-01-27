import FlowToken from 0x02
import FungibleToken from 0x01
import TokenLendingPlace from 0x04
import FUSDToken from 0x03
import BloctoToken from 0x05

// This transaction is a template for a transaction that
// could be used by anyone to send tokens to another account
// that owns a Vault
transaction() {
  prepare(acct: AuthAccount) {
      
    if acct.borrow<&AnyResource{TokenLendingPlace.TokenLendingPublic}>(from: TokenLendingPlace.CollectionStoragePath) == nil {
        let lendingPlace <- TokenLendingPlace.createTokenLendingCollection()
        acct.save(<-lendingPlace, to: /storage/TokenLendPlace)
        acct.link<&TokenLendingPlace.TokenLendingCollection{TokenLendingPlace.TokenLendingPublic}>(TokenLendingPlace.CollectionPublicPath, target: TokenLendingPlace.CollectionStoragePath)
    }

    if(acct.borrow<&FUSDToken.Vault>(from: /storage/fusdVault) == nil) {
            
        // Create a new FUSD Vault and put it in storage
        acct.save(<-FUSDToken.createEmptyVault(), to: /storage/fusdVault)

        // Create a public capability to the Vault that only exposes
        // the deposit function through the Receiver interface
        acct.link<&FUSD.Vault{FungibleToken.Receiver}>(
            /public/fusdReceiver,
            target: /storage/fusdVault
        )

        // Create a public capability to the Vault that only exposes
        // the balance field through the Balance interface
        acct.link<&FUSD.Vault{FungibleToken.Balance}>(
            /public/fusdBalance,
            target: /storage/fusdVault
        )
    }

    // If the account is already set up that's not a problem, but we don't want to replace it
    if(acct.borrow<&BloctoToken.Vault>(from: BloctoToken.TokenStoragePath) == nil) {
        // Create a new Blocto Token Vault and put it in storage
        acct.save(<-BloctoToken.createEmptyVault(), to: BloctoToken.TokenStoragePath)

        // Create a public capability to the Vault that only exposes
        // the deposit function through the Receiver interface
        acct.link<&BloctoToken.Vault{FungibleToken.Receiver}>(
            BloctoToken.TokenPublicReceiverPath,
            target: BloctoToken.TokenStoragePath
        )

        // Create a public capability to the Vault that only exposes
        // the balance field through the Balance interface
        acct.link<&BloctoToken.Vault{FungibleToken.Balance}>(
            BloctoToken.TokenPublicBalancePath,
            target: BloctoToken.TokenStoragePath
        )
    } 

  }
}
 