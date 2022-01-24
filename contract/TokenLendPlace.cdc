import FungibleToken from 0x01
import FlowToken from 0x02
import FUSD from 0x03
import BloctoToken from 0x05

pub contract TokenLendPlace {

    // Event that is emitted when a new NFT is put up for sale
    pub event Borrowed(address: Address?)


    access(contract) let tokenVaultFlow: @FlowToken.Vault
    access(contract) let tokenVaultFUSD: @FUSD.Vault
    access(contract) let tokenVaultBLT: @BloctoToken.Vault

    pub var mFlowtokenPrice: UFix64    //price only increase
    pub var mFUSDtokenPrice: UFix64
    pub var mBLTtokenPrice: UFix64

    pub var FlowTokenRealPrice: UFix64
    pub var FUSDRealPrice: UFix64
    pub var BLTTokenRealPrice: UFix64

    pub var mFlowInterestRate: UFix64
    pub var mFUSDInterestRate: UFix64 
    pub var mBLTInterestRate: UFix64 

    pub var finalTimestamp: UFix64

    pub var FlowBorrowAmountToken: UFix64
    pub var FUSDBorrowAmountToken: UFix64
    pub var BLTBorrowAmountToken: UFix64

    pub var depositeLimitFLOWToken: UFix64
    pub var depositeLimitFUSD: UFix64
    pub var depositeLimitBLTToken: UFix64

    pub var optimalUtilizationRate: UFix64
    pub var optimalBorrowApy: UFix64

    pub fun getFlowBorrowPercent(): UFix64 {
        if(TokenLendPlace.tokenVaultFlow.balance + TokenLendPlace.FlowBorrowAmountToken != 0.0){
            return TokenLendPlace.FlowBorrowAmountToken / (TokenLendPlace.tokenVaultFlow.balance + TokenLendPlace.FlowBorrowAmountToken)
        }else {
            return 0.0
        }
    }
    pub fun getFUSDBorrowPercent(): UFix64 {
        if(TokenLendPlace.tokenVaultFUSD.balance + TokenLendPlace.FUSDBorrowAmountToken != 0.0){
            return TokenLendPlace.FUSDBorrowAmountToken / (TokenLendPlace.tokenVaultFUSD.balance + TokenLendPlace.FUSDBorrowAmountToken)
        }else{
            return 0.0
        }
    }
    pub fun getBltBorrowPercent(): UFix64 {
        if(TokenLendPlace.tokenVaultBLT.balance + TokenLendPlace.BLTBorrowAmountToken != 0.0){
            return TokenLendPlace.BLTBorrowAmountToken / (TokenLendPlace.tokenVaultBLT.balance + TokenLendPlace.BLTBorrowAmountToken)
        }else{
            return 0.0
        }
    }
    pub fun getTotalsupply(): {String: UFix64} {
            return {"flowTotalSupply":TokenLendPlace.tokenVaultFlow.balance + TokenLendPlace.FlowBorrowAmountToken,"fusdTotalSupply": TokenLendPlace.tokenVaultFUSD.balance + TokenLendPlace.FUSDBorrowAmountToken, "bltTotalSupply":TokenLendPlace.tokenVaultBLT.balance + TokenLendPlace.BLTBorrowAmountToken}
    }
    pub fun getDepositLimit(): {String: UFix64} {
            return {"flowDepositLimit":TokenLendPlace.depositeLimitFLOWToken,"fusdDepositLimit": TokenLendPlace.depositeLimitFUSD, "bltDepositLimit":TokenLendPlace.depositeLimitBLTToken}
    }
    pub fun getTotalBorrow(): {String: UFix64} {
            return {"flowTotalBorrow":TokenLendPlace.FlowBorrowAmountToken,"fusdTotalBorrow": TokenLendPlace.FUSDBorrowAmountToken, "bltTotalBorrow":TokenLendPlace.BLTBorrowAmountToken}
    }
    pub fun getTokenPrice(): {String: UFix64} {
            return {"flowTokenPrice":TokenLendPlace.FlowTokenRealPrice,"fusdTokenPrice": TokenLendPlace.FUSDRealPrice, "bltTokenPrice":TokenLendPlace.BLTTokenRealPrice}
    }
    // Interface that users will publish for their Sale collection
    // that only exposes the methods that are supposed to be public
    //
    pub resource interface TokenLandPublic {
        pub fun getmFlow(): UFix64
        pub fun getmFUSD(): UFix64
        pub fun getmBLT(): UFix64
        pub fun getmyBorrowingmFlow(): UFix64
        pub fun getmyBorrowingmFUSD(): UFix64
        pub fun getmyBorrowingmBLT(): UFix64
        pub fun getMaxBorrowingPower(): UFix64
        pub fun getBorrowingNow(): UFix64
        pub fun getBorrowingPower(): UFix64
    }

    access(contract) fun updatePriceAndInterest(){
      //update token price
      //let delta = getCurrentBlock().timestamp - TokenLendPlace.finalTimestamp
      let delta = 60.0
      TokenLendPlace.mFlowtokenPrice = TokenLendPlace.mFlowtokenPrice + (delta * TokenLendPlace.mFlowInterestRate /( 365.0 * 24.0 * 60.0 * 60.0))
      TokenLendPlace.mFUSDtokenPrice = TokenLendPlace.mFUSDtokenPrice + (delta * TokenLendPlace.mFUSDInterestRate /( 365.0 * 24.0 * 60.0 * 60.0))
      TokenLendPlace.mBLTtokenPrice = TokenLendPlace.mBLTtokenPrice + (delta * TokenLendPlace.mBLTInterestRate /( 365.0 * 24.0 * 60.0 * 60.0))

      //TokenLendPlace.finalTimestamp = getCurrentBlock().timestamp
      TokenLendPlace.finalTimestamp = 0.0

      //update interestRate
      if(TokenLendPlace.tokenVaultFlow.balance + TokenLendPlace.FlowBorrowAmountToken != 0.0){
        if(TokenLendPlace.FlowBorrowAmountToken / (TokenLendPlace.tokenVaultFlow.balance + TokenLendPlace.FlowBorrowAmountToken) < TokenLendPlace.optimalUtilizationRate){
            TokenLendPlace.mFlowInterestRate = TokenLendPlace.FlowBorrowAmountToken / (TokenLendPlace.tokenVaultFlow.balance + TokenLendPlace.FlowBorrowAmountToken) / TokenLendPlace.optimalUtilizationRate * TokenLendPlace.optimalBorrowApy
        }else{
            TokenLendPlace.mFlowInterestRate = ((TokenLendPlace.FlowBorrowAmountToken / (TokenLendPlace.tokenVaultFlow.balance + TokenLendPlace.FlowBorrowAmountToken)) - TokenLendPlace.optimalUtilizationRate)/(1.0-TokenLendPlace.optimalUtilizationRate)*(1.0-TokenLendPlace.optimalUtilizationRate)+TokenLendPlace.optimalUtilizationRate
        }
      }
      if(TokenLendPlace.tokenVaultFUSD.balance + TokenLendPlace.FUSDBorrowAmountToken != 0.0){
        if(TokenLendPlace.FUSDBorrowAmountToken / (TokenLendPlace.tokenVaultFUSD.balance + TokenLendPlace.FUSDBorrowAmountToken) < TokenLendPlace.optimalUtilizationRate){
            TokenLendPlace.mFUSDInterestRate = TokenLendPlace.FUSDBorrowAmountToken / (TokenLendPlace.tokenVaultFUSD.balance + TokenLendPlace.FUSDBorrowAmountToken)/ TokenLendPlace.optimalUtilizationRate*TokenLendPlace.optimalBorrowApy
        }else{
            TokenLendPlace.mFUSDInterestRate = ((TokenLendPlace.FUSDBorrowAmountToken / (TokenLendPlace.tokenVaultFUSD.balance + TokenLendPlace.FUSDBorrowAmountToken)) - TokenLendPlace.optimalUtilizationRate)/(1.0-TokenLendPlace.optimalUtilizationRate)*(1.0-TokenLendPlace.optimalUtilizationRate)+TokenLendPlace.optimalUtilizationRate
        }
      }
      if(TokenLendPlace.tokenVaultBLT.balance + TokenLendPlace.BLTBorrowAmountToken != 0.0){
        if(TokenLendPlace.BLTBorrowAmountToken / (TokenLendPlace.tokenVaultBLT.balance + TokenLendPlace.BLTBorrowAmountToken) < TokenLendPlace.optimalUtilizationRate){
            TokenLendPlace.mBLTInterestRate = TokenLendPlace.BLTBorrowAmountToken / (TokenLendPlace.tokenVaultBLT.balance + TokenLendPlace.BLTBorrowAmountToken)/ TokenLendPlace.optimalUtilizationRate*TokenLendPlace.optimalBorrowApy
        }else{
            TokenLendPlace.mBLTInterestRate = ((TokenLendPlace.BLTBorrowAmountToken / (TokenLendPlace.tokenVaultBLT.balance + TokenLendPlace.BLTBorrowAmountToken)) - TokenLendPlace.optimalUtilizationRate)/(1.0-TokenLendPlace.optimalUtilizationRate)*(1.0-TokenLendPlace.optimalUtilizationRate)+TokenLendPlace.optimalUtilizationRate
        }
      }
    
    }

    //TODO, waiting real feed source, and limit certain caller.
    pub fun updatePricefromOracle(_FlowPrice: UFix64, _FUSDPrice: UFix64, _BLTPrice: UFix64){
      self.FlowTokenRealPrice = _FlowPrice
      self.FUSDRealPrice = _FUSDPrice
      self.BLTTokenRealPrice = _BLTPrice
    }

    // SaleCollection
    //
    // NFT Collection object that allows a user to put their NFT up for sale
    // where others can send fungible tokens to purchase it
    //
    pub resource TokenLandCollection: TokenLandPublic {

        access(self) var mFlow: UFix64
        access(self) var mFUSD: UFix64
        access(self) var mBLT: UFix64

        access(self) var myBorrowingmFlow: UFix64
        access(self) var myBorrowingmFUSD: UFix64
        access(self) var myBorrowingmBLT: UFix64

        init () {
            self.mFlow = 0.0
            self.mFUSD = 0.0
            self.mBLT = 0.0

            self.myBorrowingmFlow = 0.0
            self.myBorrowingmFUSD = 0.0
            self.myBorrowingmBLT = 0.0
        }

        pub fun getmFlow(): UFix64 {
            return self.mFlow
        }
        pub fun getmFUSD(): UFix64 {
            return self.mFUSD
        }
        pub fun getmBLT(): UFix64 {
            return self.mBLT
        }
        pub fun getmyBorrowingmFlow(): UFix64 {
            return self.myBorrowingmFlow
        }
        pub fun getmyBorrowingmFUSD(): UFix64 {
            return self.myBorrowingmFUSD
        }
        pub fun getmyBorrowingmBLT(): UFix64 {
            return self.myBorrowingmBLT
        }

   
        pub fun addLiquidity(from: @FungibleToken.Vault) {
            pre {
            }

            if(from.getType() == Type<@FlowToken.Vault>()) {
                let balance = from.balance
                TokenLendPlace.tokenVaultFlow.deposit(from: <- from)
                self.mFlow = self.mFlow + (balance / TokenLendPlace.mFlowtokenPrice)
            } else if( from.getType() == Type<@FUSD.Vault>()) {
                let balance = from.balance
                TokenLendPlace.tokenVaultFUSD.deposit(from: <- from)
                self.mFUSD = self.mFUSD + (balance / TokenLendPlace.mFUSDtokenPrice)
            } else if( from.getType() == Type<@BloctoToken.Vault>()) {
                let balance = from.balance
                TokenLendPlace.tokenVaultBLT.deposit(from: <- from)
                self.mBLT = self.mBLT + (balance / TokenLendPlace.mBLTtokenPrice)
            }

            TokenLendPlace.updatePriceAndInterest()
            //event
        }

        pub fun removeLiquidity(_amount: UFix64, _token: Int): @FungibleToken.Vault {

            if(_token == 0) {
                self.mFlow = self.mFlow - _amount
                let tokenVault <- TokenLendPlace.tokenVaultFlow.withdraw(amount: (_amount * TokenLendPlace.mFlowtokenPrice)) 
                TokenLendPlace.updatePriceAndInterest()
                //event
                 return <- tokenVault
            } else if(_token == 1) {
                self.mFUSD = self.mFUSD - _amount
                let tokenVault <- TokenLendPlace.tokenVaultFUSD.withdraw(amount: (_amount * TokenLendPlace.mFUSDtokenPrice)) 
                TokenLendPlace.updatePriceAndInterest()
                //event
                 return <- tokenVault
            } else {
                self.mBLT = self.mBLT - _amount
                let tokenVault <- TokenLendPlace.tokenVaultBLT.withdraw(amount: (_amount * TokenLendPlace.mBLTtokenPrice)) 
                TokenLendPlace.updatePriceAndInterest()
                //event
                 return <- tokenVault
            }

        }

        pub fun getBorrowingPower(): UFix64 {
            
            //美元計價
            let FlowPower = (self.mFlow - self.myBorrowingmFlow) * TokenLendPlace.mFlowtokenPrice * TokenLendPlace.FlowTokenRealPrice
            let FUSDPower = (self.mFUSD - self.myBorrowingmFUSD) * TokenLendPlace.mFUSDtokenPrice * TokenLendPlace.FUSDRealPrice 
            let BLTPower = (self.mBLT - self.myBorrowingmBLT) * TokenLendPlace.mBLTtokenPrice * TokenLendPlace.BLTTokenRealPrice 

            return FlowPower + FUSDPower + BLTPower
        }

        pub fun getMaxBorrowingPower(): UFix64 {
            
            //美元計價
            let FlowPower = self.mFlow * TokenLendPlace.mFlowtokenPrice * TokenLendPlace.FlowTokenRealPrice 
            let FUSDPower = self.mFUSD * TokenLendPlace.mFUSDtokenPrice * TokenLendPlace.FUSDRealPrice
            let BLTPower = self.mBLT * TokenLendPlace.mBLTtokenPrice * TokenLendPlace.BLTTokenRealPrice

            return FlowPower + FUSDPower + BLTPower
        }
        pub fun getBorrowingNow(): UFix64 {
            
            //美元計價
            let FlowBorrow = self.myBorrowingmFlow * TokenLendPlace.mFlowtokenPrice * TokenLendPlace.FlowTokenRealPrice 
            let FUSDBorrow = self.myBorrowingmFUSD * TokenLendPlace.mFUSDtokenPrice * TokenLendPlace.FUSDRealPrice
            let BLTBorrow = self.myBorrowingmBLT * TokenLendPlace.mBLTtokenPrice * TokenLendPlace.BLTTokenRealPrice

            return FlowBorrow + FUSDBorrow + BLTBorrow
        }

        pub fun borrowFlow(_amount: UFix64): @FungibleToken.Vault {
            pre {
                TokenLendPlace.tokenVaultFlow.balance - TokenLendPlace.FlowBorrowAmountToken > _amount: "Amount minted must be greater than zero"
                (self.getBorrowingPower() * 0.6) > (TokenLendPlace.FlowTokenRealPrice * _amount) : "Amount minted must be greater than zero"
            }

            emit Borrowed(address: self.owner?.address)
            
            let realAmountofToken = _amount * TokenLendPlace.mFlowtokenPrice
            TokenLendPlace.FlowBorrowAmountToken = realAmountofToken + TokenLendPlace.FlowBorrowAmountToken

            self.myBorrowingmFlow = _amount + self.myBorrowingmFlow

            let token1Vault <- TokenLendPlace.tokenVaultFlow.withdraw(amount: realAmountofToken)
            TokenLendPlace.updatePriceAndInterest()
            return <- token1Vault
        }
        pub fun borrowFUSD(_amount: UFix64): @FungibleToken.Vault {
            pre {
                TokenLendPlace.tokenVaultFUSD.balance - TokenLendPlace.FUSDBorrowAmountToken > _amount: "Amount minted must be greater than zero"
                (self.getBorrowingPower() * 0.6) > (TokenLendPlace.FUSDRealPrice * _amount) : "Amount minted must be greater than zero"
            }

            emit Borrowed(address: self.owner?.address)
            
            let realAmountofToken = _amount * TokenLendPlace.mFUSDtokenPrice
            TokenLendPlace.FUSDBorrowAmountToken = realAmountofToken + TokenLendPlace.FUSDBorrowAmountToken

            self.myBorrowingmFUSD = _amount + self.myBorrowingmFUSD

            let token1Vault <- TokenLendPlace.tokenVaultFUSD.withdraw(amount: realAmountofToken)
            TokenLendPlace.updatePriceAndInterest()
            return <- token1Vault
        }
        pub fun borrowBLT(_amount: UFix64): @FungibleToken.Vault {
            pre {
                TokenLendPlace.tokenVaultBLT.balance - TokenLendPlace.BLTBorrowAmountToken > _amount: "Amount minted must be greater than zero"
                (self.getBorrowingPower() * 0.6) > (TokenLendPlace.BLTTokenRealPrice * _amount) : "Amount minted must be greater than zero"
            }

            emit Borrowed(address: self.owner?.address)
            

            let realAmountofToken = _amount * TokenLendPlace.mBLTtokenPrice
            TokenLendPlace.BLTBorrowAmountToken = realAmountofToken + TokenLendPlace.BLTBorrowAmountToken

            self.myBorrowingmBLT = _amount + self.myBorrowingmBLT

            let token1Vault <- TokenLendPlace.tokenVaultBLT.withdraw(amount: realAmountofToken)
            TokenLendPlace.updatePriceAndInterest()
            return <- token1Vault
        }

        //Repay
        pub fun repayFlow(from: @FlowToken.Vault){
            //unlock the borrowing power

            TokenLendPlace.FlowBorrowAmountToken = TokenLendPlace.FlowBorrowAmountToken - from.balance
            self.myBorrowingmFlow = self.myBorrowingmFlow - (from.balance / TokenLendPlace.mFlowtokenPrice)

            TokenLendPlace.tokenVaultFlow.deposit(from: <- from )
            TokenLendPlace.updatePriceAndInterest()
        }
        pub fun repayFUSD(from: @FUSD.Vault){
            //unlock the borrowing power


            TokenLendPlace.FUSDBorrowAmountToken = TokenLendPlace.FUSDBorrowAmountToken - from.balance
            self.myBorrowingmFUSD = self.myBorrowingmFUSD - (from.balance / TokenLendPlace.mFUSDtokenPrice)

            TokenLendPlace.tokenVaultFUSD.deposit(from: <- from )
            TokenLendPlace.updatePriceAndInterest()
        }
        pub fun repayBLT(from: @BloctoToken.Vault){
            //unlock the borrowing power
            TokenLendPlace.BLTBorrowAmountToken = TokenLendPlace.BLTBorrowAmountToken - from.balance
            self.myBorrowingmBLT = self.myBorrowingmBLT - (from.balance / TokenLendPlace.mBLTtokenPrice)

            TokenLendPlace.tokenVaultBLT.deposit(from: <- from )
            TokenLendPlace.updatePriceAndInterest()
        }


        pub fun liquidateFlow(from: @FungibleToken.Vault, liquidatorVault: &TokenLandCollection){
            
            //flow in flow out
            if(from.getType() == Type<@FlowToken.Vault>()) {
                self.myBorrowingmFlow = self.myBorrowingmFlow - (from.balance / TokenLendPlace.mFlowtokenPrice)

                let repaymoney = from.balance * 1.05

                liquidatorVault.depositemFlow(from:(repaymoney / TokenLendPlace.mFlowtokenPrice))

                TokenLendPlace.tokenVaultFlow.deposit(from: <- from)

                self.mFlow = self.mFlow - (repaymoney / TokenLendPlace.mFlowtokenPrice)

                //let token1Vault <- TokenLendPlace.tokenVaultFlow.withdraw(amount: repaymoney)
                //return <- token1Vault
            } else if( from.getType() == Type<@FUSD.Vault>()) 
            {
                TokenLendPlace.FUSDBorrowAmountToken = TokenLendPlace.FUSDBorrowAmountToken - from.balance
                self.myBorrowingmFUSD = self.myBorrowingmFUSD - (from.balance / TokenLendPlace.mFUSDtokenPrice)
                
                let repaymoney = from.balance * 1.05 / TokenLendPlace.FlowTokenRealPrice

                liquidatorVault.depositemFUSD(from:(repaymoney / TokenLendPlace.mFUSDtokenPrice))

                TokenLendPlace.tokenVaultFUSD.deposit(from: <- from)

                self.mFlow = self.mFlow - (repaymoney / TokenLendPlace.mFlowtokenPrice)

                //let tokenVault <- TokenLendPlace.tokenVaultFlow.withdraw(amount: repaymoney)
                //return <- tokenVault
            } else if( from.getType() == Type<@BloctoToken.Vault>())  {
                 TokenLendPlace.BLTBorrowAmountToken = TokenLendPlace.BLTBorrowAmountToken - from.balance
                self.myBorrowingmBLT = self.myBorrowingmBLT - (from.balance / TokenLendPlace.mBLTtokenPrice)
                
                let repaymoney = from.balance * 1.05 / TokenLendPlace.BLTTokenRealPrice

                liquidatorVault.depositemBLT(from:(repaymoney / TokenLendPlace.mBLTtokenPrice))

                TokenLendPlace.tokenVaultBLT.deposit(from: <- from)

                self.mBLT = self.mBLT - (repaymoney / TokenLendPlace.mBLTtokenPrice)
            }
            TokenLendPlace.updatePriceAndInterest()
        }
        access(self) fun depositemFlow(from: UFix64) {
            self.mFlow = self.mFlow + from
        }
        access(self) fun depositemFUSD(from: UFix64) {
            self.mFUSD = self.mFUSD + from
        }
        access(self) fun depositemBLT(from: UFix64) {
            self.mBLT = self.mBLT + from
        }
    }

    // createCollection returns a new collection resource to the caller
    pub fun createTokenLandCollection(): @TokenLandCollection {
        return <- create TokenLandCollection()
    }

    init() {
        self.tokenVaultFlow <- FlowToken.createEmptyVault() as! @FlowToken.Vault
        self.tokenVaultFUSD <- FUSD.createEmptyVault() as! @FUSD.Vault
        self.tokenVaultBLT <- BloctoToken.createEmptyVault() as! @BloctoToken.Vault

        self.mFlowInterestRate = 0.0
        self.mFUSDInterestRate = 0.0
        self.mBLTInterestRate = 0.0
        self.mFlowtokenPrice = 1.0
        self.mFUSDtokenPrice = 1.0
        self.mBLTtokenPrice = 1.0
        self.FlowTokenRealPrice = 10.0
        self.FUSDRealPrice = 1.0
        self.BLTTokenRealPrice = 4.0
        self.finalTimestamp = 0.0 //getCurrentBlock().height

        self.FlowBorrowAmountToken = 0.0
        self.FUSDBorrowAmountToken = 0.0
        self.BLTBorrowAmountToken = 0.0

        self.depositeLimitFLOWToken = 100000.0
        self.depositeLimitFUSD = 1000000.0
        self.depositeLimitBLTToken = 1000000.0

        self.optimalUtilizationRate = 0.8
        self.optimalBorrowApy = 0.08


  }
}
 
