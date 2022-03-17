import FlowToken from 0x02
import FiatToken from 0x03
import FungibleToken from 0x01
import TokenLendingPlace from 0x04


// This transaction is a template for a transaction that
// could be used by anyone to send tokens to another account
// that owns a Vault
transaction(borrowerAddress: Address) {


  // Temporary Vault object that holds the balance that is being transferred
  var liquidatorPlace: &TokenLendingPlace.TokenLendingCollection
  var lendingPlaceRef : &TokenLendingPlace.TokenLendingCollection
  var supplyId: UInt64
  var borrowId: UInt64


  prepare(acct: AuthAccount) {
    if (acct.borrow<&TokenLendingPlace.UserCertificate>(from: TokenLendingPlace.CertificateStoragePath) == nil) {
      let userCertificate <- TokenLendingPlace.createCertificate()
      acct.save(<-userCertificate, to: TokenLendingPlace.CertificateStoragePath)
      acct.link<&TokenLendingPlace.UserCertificate>(TokenLendingPlace.CertificatePrivatePath, target: TokenLendingPlace.CertificateStoragePath)
    }

    ifTokenLendingPlace.borrowCollection(address: acct.address) == nil {
      let userCertificateCap = acct.getCapability<&TokenLendingPlace.UserCertificate>(TokenLendingPlace.CertificatePrivatePath)
      TokenLendingPlace.createTokenLendingCollection(_cer: userCertificateCap)
    }

    self.liquidatorPlace = TokenLendingPlace.borrowCollection(address: acct.address)
                    ?? panic("No collection with that address in TokenLendingPlace")

self.lendingPlaceRef = TokenLendingPlace.borrowCollection(address:borrowerAddress)
                    ?? panic("No collection with that address in TokenLendingPlace")

    let supplyFlow = self.lendingPlaceRef.getmFlow()*TokenLendingPlace.getmFlowTokenPrice()*TokenLendingPlace.FlowTokenRealPrice
    let supplyFiatToken = self.lendingPlaceRef.getmFiatToken()*TokenLendingPlace.getmFiatTokenTokenPrice()*TokenLendingPlace.FiatTokenRealPrice
    let borrowFlow = self.lendingPlaceRef.getMyBorrowingmFlow()*TokenLendingPlace.getmFlowBorrowingTokenPrice()*TokenLendingPlace.FlowTokenRealPrice
    let borrowFiatToken  = self.lendingPlaceRef.getMyBorrowingmFiatToken()*TokenLendingPlace.getmFiatTokenBorrowingTokenPrice()*TokenLendingPlace.FiatTokenRealPrice
    var supplyArray = [supplyFlow, supplyFiatToken]
    var borrowArray = [borrowFlow, borrowFiatToken]
    var largestSupply = supplyFlow
    var largestBorrow = borrowFlow
    var counter = (0 as UInt64)
    self.supplyId = 0
    while counter <= 1 {
      if (largestSupply < supplyArray[counter] ) {
        largestSupply = supplyArray[counter];
        self.supplyId = counter
    }
      counter = counter + 1
    }
    var counter2 = (1 as UInt64)
     self.borrowId = 0
    while counter2 <= 1 {
      if (largestBorrow < borrowArray[counter2] ) {
        largestBorrow = borrowArray[counter2];
        self.borrowId = counter2
    }
      counter2 = counter2 + 1
    }
    var liauidateAmount = 0.0
    if(largestSupply > largestBorrow){
      liauidateAmount = largestBorrow / 2.0
    }else{
      liauidateAmount = largestSupply / 2.0
    }
    if(self.borrowId == 0){
      let vaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
        ?? panic("Could not borrow a reference to the owner's vault")
        var temporaryVault <- vaultRef.withdraw(amount: liauidateAmount/TokenLendingPlace.FlowTokenRealPrice)
        if(self.supplyId == 0){
          self.lendingPlaceRef.liquidateFlow(from: <- temporaryVault, liquidatorVault: self.liquidatorPlace)
        }else{
          self.lendingPlaceRef.liquidateFiatToken(from: <- temporaryVault, liquidatorVault: self.liquidatorPlace)
        }
    }else{
      let vaultRef = acct.borrow<&FiatToken.Vault>(from: FiatToken.VaultStoragePath)
        ?? panic("Could not borrow a reference to the owner's vault")
         var temporaryVault <- vaultRef.withdraw(amount: liauidateAmount/TokenLendingPlace.FiatTokenRealPrice)
        if(self.supplyId == 0){
          self.lendingPlaceRef.liquidateFlow(from: <- temporaryVault, liquidatorVault: self.liquidatorPlace)
        }else{
          self.lendingPlaceRef.liquidateFiatToken(from: <- temporaryVault, liquidatorVault: self.liquidatorPlace)
        }
    }
  }

  execute {
    log("Liquidate succeeded!")
  }
}
