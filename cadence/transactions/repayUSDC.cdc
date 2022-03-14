import FiatToken from 0xa983fecbed621163
import TokenLendingPlace from 0xc38610288f1f6e88

transaction(amount: UFix64) {

    // Temporary vault object which holds the transferred balance
    var temporaryVault: @FiatToken.Vault
    var lendingPlace: &TokenLendingPlace.TokenLendingCollection
    var userCertificateCap: Capability<&TokenLendingPlace.UserCertificate>

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

        // Borrow a reference of valut and withdraw tokens, then call the withdraw function with that reference
        let vaultRef = acct.borrow<&FiatToken.Vault>(from: FiatToken.VaultStoragePath)
            ?? panic("Could not borrow a reference to the owner's FiatToken vault")

        self.temporaryVault <- vaultRef.withdraw(amount: amount) as! @FiatToken.Vault

        self.userCertificateCap = acct.getCapability<&TokenLendingPlace.UserCertificate>(TokenLendingPlace.CertificatePrivatePath)

        self.lendingPlace = TokenLendingPlace.borrowCollection(address: acct.address)
                    ?? panic("No collection with that address in TokenLendingPlace")
    }

    execute {
        self.lendingPlace.repayFiatToken(from: <-self.temporaryVault, _cer: self.userCertificateCap)

        log("Repay succeeded")
    }
}
