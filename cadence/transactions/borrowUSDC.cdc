import FlowToken from 0x7e60df042a9c0868
import TokenLendingPlace from 0xc38610288f1f6e88
transaction(amount: UFix64) {

    // Temporary vault object which holds the transferred balance
    var vaultRef: &FiatToken.Vault
    var lendingPlace: &TokenLendingPlace.TokenLendingCollection
    var userCertificateCap: Capability<&TokenLendingPlace.UserCertificate>

    prepare(acct: AuthAccount) {
    if (acct.borrow<&TokenLendingPlace.UserCertificate>(from: TokenLendingPlace.CertificateStoragePath) == nil) {
      let userCertificate <- TokenLendingPlace.createCertificate()
      acct.save(<-userCertificate, to: TokenLendingPlace.CertificateStoragePath)
      acct.link<&TokenLendingPlace.UserCertificate>(TokenLendingPlace.CertificatePrivatePath, target: TokenLendingPlace.CertificateStoragePath)
    }

    if TokenLendingPlace.borrowCollection(address: acct.address) == nil {
      let userCertificateCap = acct.getCapability<&TokenLendingPlace.UserCertificate>(TokenLendingPlace.CertificatePrivatePath)
      TokenLendingPlace.createTokenLendingCollection(_cer: userCertificateCap)
    }

        // Borrow a reference of valut and withdraw tokens, then call the deposit function with that reference
        self.vaultRef = acct.borrow<&FiatToken.Vault>(from: FiatToken.VaultStoragePath)
            ?? panic("Could not borrow a reference to the owner's FiatToken vault")

        self.userCertificateCap = acct.getCapability<&TokenLendingPlace.UserCertificate>(TokenLendingPlace.CertificatePrivatePath)

        self.lendingPlace = TokenLendingPlace.borrowCollection(address: acct.address)
                    ?? panic("No collection with that address in TokenLendingPlace")
    }

    execute {
        var vault <- self.lendingPlace.borrowFiatToken(_amount: amount, _cer: self.userCertificateCap)

        self.vaultRef.deposit(from: <-vault)

        log("Borrow succeeded")
    }
}


