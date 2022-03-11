import FlowToken from 0x02
import TokenLendingPlace from 0x04

transaction(amount: UFix64) {

    // Temporary vault object which holds the transferred balance
    var temporaryVault: @FlowToken.Vault
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
        let vaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Could not borrow a reference to the owner's FLOW vault")
        
        self.temporaryVault <- vaultRef.withdraw(amount: amount) as! @FlowToken.Vault

            self.userCertificateCap = acct.getCapability<&TokenLendingPlace.UserCertificate>(TokenLendingPlace.CertificatePrivatePath)

         self.lendingPlace = TokenLendingPlace.borrowCollection(address: acct.address)
                    ?? panic("No collection with that address in TokenLendingPlace")
    }

    execute {
        self.lendingPlace.repayFlow(from: <-self.temporaryVault, _cer: self.userCertificateCap)

        log("Transfer succeeded")
    }
}
 