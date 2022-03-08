import FlowToken from 0xf8d6e0586b0a20c7
import FUSD from 0xf8d6e0586b0a20c7
import FungibleToken from 0xee82856bf20e2aa6
import TokenLendingPlace from 0xf8d6e0586b0a20c7


// This transaction is a template for a transaction that
// could be used by anyone to send tokens to another account
// that owns a Vault
transaction(borrowerAddress: Address) {


  // Temporary Vault object that holds the balance that is being transferred
  var liquidatorPlace: &TokenLendingPlace.TokenLendingCollection
  var lendingPlaceRef : &AnyResource{TokenLendingPlace.TokenLendingPublic}
  var supplyId: UInt64
  var borrowId: UInt64


  prepare(acct: AuthAccount) {
   if acct.borrow<&AnyResource{TokenLendingPlace.TokenLendingPublic}>(from: TokenLendingPlace.CollectionStoragePath) == nil {
            let lendingPlace <- TokenLendingPlace.createTokenLendingCollection()
            acct.save(<-lendingPlace, to: TokenLendingPlace.CollectionStoragePath)
            acct.link<&TokenLendingPlace.TokenLendingCollection{TokenLendingPlace.TokenLendingPublic}>(TokenLendingPlace.CollectionPublicPath, target: TokenLendingPlace.CollectionStoragePath)
        }

    self.liquidatorPlace = acct.borrow<&TokenLendingPlace.TokenLendingCollection>(from: TokenLendingPlace.CollectionStoragePath)
            ?? panic("Could not borrow owner''s vault reference2")
    let account1 = getAccount(borrowerAddress)
     let borrower = getAccount(borrowerAddress)

     self.lendingPlaceRef = borrower.getCapability<&AnyResource{TokenLendingPlace.TokenLendingPublic}>(TokenLendingPlace.CollectionPublicPath)
            .borrow()
            ?? panic("Could not borrow borrower''s NFT Lending Place recource")
    let supplyFlow = self.lendingPlaceRef.getmFlow()*TokenLendingPlace.getmFlowTokenPrice()*TokenLendingPlace.FlowTokenRealPrice
    let supplyFUSD = self.lendingPlaceRef.getmFUSD()*TokenLendingPlace.getmFUSDTokenPrice()*TokenLendingPlace.FUSDRealPrice
    let borrowFlow = self.lendingPlaceRef.getMyBorrowingmFlow()*TokenLendingPlace.getmFlowBorrowingTokenPrice()*TokenLendingPlace.FlowTokenRealPrice
    let borrowFUSD  = self.lendingPlaceRef.getMyBorrowingmFUSD()*TokenLendingPlace.getmFUSDBorrowingTokenPrice()*TokenLendingPlace.FUSDRealPrice
    var supplyArray = [supplyFlow, supplyFUSD]
    var borrowArray = [borrowFlow, borrowFUSD]
    var largestSupply = supplyFlow
    var largestBorrow = borrowFlow
    var counter = (1 as UInt64)
    self.supplyId = 0
    while counter <= 2 {
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
      liauidateAmount = largestBorrow
    }else{
      liauidateAmount = largestSupply
    }
    if(self.borrowId == 0){
      let vaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
        ?? panic("Could not borrow a reference to the owner''s vault")
        var temporaryVault <- vaultRef.withdraw(amount: liauidateAmount/TokenLendingPlace.FlowTokenRealPrice)
        if(self.supplyId == 0){
          self.lendingPlaceRef.liquidateFlow(from: <- temporaryVault, liquidatorVault: self.liquidatorPlace)
        }else(self.supplyId == 1){
          self.lendingPlaceRef.liquidateFUSD(from: <- temporaryVault, liquidatorVault: self.liquidatorPlace)
        }
    }else if(self.borrowId == 1){
      let vaultRef = acct.borrow<&FUSD.Vault>(from: /storage/fusdVault)
        ?? panic("Could not borrow a reference to the owner''s vault")
         var temporaryVault <- vaultRef.withdraw(amount: liauidateAmount/TokenLendingPlace.FUSDRealPrice)
        if(self.supplyId == 0){
          self.lendingPlaceRef.liquidateFlow(from: <- temporaryVault, liquidatorVault: self.liquidatorPlace)
        }else(self.supplyId == 1){
          self.lendingPlaceRef.liquidateFUSD(from: <- temporaryVault, liquidatorVault: self.liquidatorPlace)
        }
    }
  }

  execute {
    log("Liquidate succeeded!")
  }
}