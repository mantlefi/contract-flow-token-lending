import FungibleToken from 0xee82856bf20e2aa6
import TokenLendingPlace from 0xf8d6e0586b0a20c7
import FiatToken from 0xf8d6e0586b0a20c7

// A template of transaction which could send tokens to other accounts with a vault by anyone
// This transaction is a template for a transaction that
// could be used by anyone to send tokens to another account
// that owns a Vault
transaction() {
  prepare(acct: AuthAccount) {
    if (acct.borrow<&TokenLendingPlace.UserCertificate>(from: TokenLendingPlace.CertificateStoragePath) == nil) {
let userCertificate <- TokenLendingPlace.createCertificate()
acct.save(<-userCertificate, to: TokenLendingPlace.CertificateStoragePath)
acct.link<&TokenLendingPlace.UserCertificate>(TokenLendingPlace.CertificatePrivatePath, target: TokenLendingPlace.CertificateStoragePath)
}
    if TokenLendingPlace.lendingClollection[acct.address] == nil {
    let userCertificateCap = acct.getCapability<&TokenLendingPlace.UserCertificate>(TokenLendingPlace.CertificatePrivatePath)

        TokenLendingPlace.createTokenLendingCollection(_cer: userCertificateCap)
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
        if (acct.borrow<&FiatToken.Vault>(from: FiatToken.VaultStoragePath) == nil) {

        // Create a new FiatToken vault and put it in storage
        acct.save(<-FiatToken.createEmptyVault(), to: FiatToken.VaultStoragePath)

        // Create a public capability to the vault
        // which only exposes deposit function through receiver interface
        acct.link<&FiatToken.Vault{FungibleToken.Receiver}>(
            FiatToken.VaultReceiverPubPath,
            target: FiatToken.VaultStoragePath
        )

        // Create a public capability to the vault which only exposes
        // balance field through balance interface
        acct.link<&FiatToken.Vault{FungibleToken.Balance}>(
            FiatToken.VaultBalancePubPath,
            target: FiatToken.VaultStoragePath
        )
    }

  }
}
 
 