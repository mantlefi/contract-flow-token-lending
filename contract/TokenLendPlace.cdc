import FungibleToken from 0x01
import FlowToken from 0x02
import FUSD from 0x03
import BloctoToken from 0x05

pub contract TokenLendingPlace {

    // Event that is emitted when 有人被清算時 (補上，清算幣種-入，金額，回傳金額-出）
    pub event Borrowed(address: Address?)

    //補上事件 - 有人進行deposite(Address, 幣種, 金額）

    //補上事件 - 有人進行withdraw(Address, 幣種, 金額）

    //補上事件 - 有人進行borrow(Address, 幣種, 金額）

    //補上事件 - 有人進行borrow(Address, 幣種, 金額, total borrow）

    //補上事件 - 有人進行repay(Address, 幣種, 金額, ???, total borrow）

    //補上事件 - 有人進行清算(Address, 幣種, 金額, total borrow）

    //以上事件請參考：https://compound.finance/docs/ctokens#key-events


    //協議中存放真實代幣的地方
    access(contract) let tokenVaultFlow: @FlowToken.Vault
    access(contract) let tokenVaultFUSD: @FUSD.Vault
    access(contract) let tokenVaultBLT: @BloctoToken.Vault

    //協議中的代幣皆採用 mToken 為代表，mToken 價格僅會往上升，而不會下降。
    pub var mFlowtokenPrice: UFix64 
    pub var mFUSDtokenPrice: UFix64
    pub var mBLTtokenPrice: UFix64

    //協議中各項token的真實價格，由預言機與Admin進行更新
    pub var FlowTokenRealPrice: UFix64
    pub var FUSDRealPrice: UFix64
    pub var BLTTokenRealPrice: UFix64

    //協議中mtoken更新的斜率
    pub var mFlowInterestRate: UFix64
    pub var mFUSDInterestRate: UFix64 
    pub var mBLTInterestRate: UFix64 

    //協議中mToken最後更新的時間
    pub var finalTimestamp: UFix64

    //協議中目前代幣被借出的總數量，此金額將影響利率的計算
    pub var FlowBorrowAmountToken: UFix64
    pub var FUSDBorrowAmountToken: UFix64
    pub var BLTBorrowAmountToken: UFix64

    //協議中限制代幣存放與領出的數量
    pub var depositeLimitFLOWToken: UFix64
    pub var depositeLimitFUSD: UFix64
    pub var depositeLimitBLTToken: UFix64

    //協議中各項利率優化的參與指標
    pub var optimalUtilizationRate: UFix64
    pub var optimalBorrowApy: UFix64

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath

    pub fun getFlowBorrowPercent(): UFix64 {
        if(TokenLendingPlace.tokenVaultFlow.balance + TokenLendingPlace.FlowBorrowAmountToken != 0.0){
            return TokenLendingPlace.FlowBorrowAmountToken / (TokenLendingPlace.tokenVaultFlow.balance + TokenLendingPlace.FlowBorrowAmountToken)
        }else {
            return 0.0
        }
    }

    pub fun getFUSDBorrowPercent(): UFix64 {
        if(TokenLendingPlace.tokenVaultFUSD.balance + TokenLendingPlace.FUSDBorrowAmountToken != 0.0){
            return TokenLendingPlace.FUSDBorrowAmountToken / (TokenLendingPlace.tokenVaultFUSD.balance + TokenLendingPlace.FUSDBorrowAmountToken)
        }else{
            return 0.0
        }
    }

    pub fun getBltBorrowPercent(): UFix64 {
        if(TokenLendingPlace.tokenVaultBLT.balance + TokenLendingPlace.BLTBorrowAmountToken != 0.0){
            return TokenLendingPlace.BLTBorrowAmountToken / (TokenLendingPlace.tokenVaultBLT.balance + TokenLendingPlace.BLTBorrowAmountToken)
        }else{
            return 0.0
        }
    }

    pub fun getTotalsupply(): {String: UFix64} {
            return {"flowTotalSupply":TokenLendingPlace.tokenVaultFlow.balance + TokenLendingPlace.FlowBorrowAmountToken,"fusdTotalSupply": TokenLendingPlace.tokenVaultFUSD.balance + TokenLendingPlace.FUSDBorrowAmountToken, "bltTotalSupply":TokenLendingPlace.tokenVaultBLT.balance + TokenLendingPlace.BLTBorrowAmountToken}
    }

    pub fun getDepositLimit(): {String: UFix64} {
            return {"flowDepositLimit":TokenLendingPlace.depositeLimitFLOWToken,"fusdDepositLimit": TokenLendingPlace.depositeLimitFUSD, "bltDepositLimit":TokenLendingPlace.depositeLimitBLTToken}
    }

    pub fun getTotalBorrow(): {String: UFix64} {
            return {"flowTotalBorrow":TokenLendingPlace.FlowBorrowAmountToken,"fusdTotalBorrow": TokenLendingPlace.FUSDBorrowAmountToken, "bltTotalBorrow":TokenLendingPlace.BLTBorrowAmountToken}
    }

    pub fun getTokenPrice(): {String: UFix64} {
            return {"flowTokenPrice":TokenLendingPlace.FlowTokenRealPrice,"fusdTokenPrice": TokenLendingPlace.FUSDRealPrice, "bltTokenPrice":TokenLendingPlace.BLTTokenRealPrice}
    }

    // Interface that users will publish for their lending collection
    // that only exposes the methods that are supposed to be public
    //
    pub resource interface TokenLendingPublic {
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

    //協議中更新 mToken 與利率的方法，任何有更動協議裡金額的部分（deposite, repay, withdrea, borrow, liquidty)都會呼叫此方法。在此方法中我們即時更新最新的利率。
    access(contract) fun updatePriceAndInterest(){
      //update token price
      //let delta = getCurrentBlock().timestamp - TokenLendingPlace.finalTimestamp
      let delta = 60.0
      TokenLendingPlace.mFlowtokenPrice = TokenLendingPlace.mFlowtokenPrice + (delta * TokenLendingPlace.mFlowInterestRate /( 365.0 * 24.0 * 60.0 * 60.0))
      TokenLendingPlace.mFUSDtokenPrice = TokenLendingPlace.mFUSDtokenPrice + (delta * TokenLendingPlace.mFUSDInterestRate /( 365.0 * 24.0 * 60.0 * 60.0))
      TokenLendingPlace.mBLTtokenPrice = TokenLendingPlace.mBLTtokenPrice + (delta * TokenLendingPlace.mBLTInterestRate /( 365.0 * 24.0 * 60.0 * 60.0))

      //TokenLendingPlace.finalTimestamp = getCurrentBlock().timestamp
      TokenLendingPlace.finalTimestamp = 0.0

      //update interestRate
      if(TokenLendingPlace.tokenVaultFlow.balance + TokenLendingPlace.FlowBorrowAmountToken != 0.0){
        if(TokenLendingPlace.FlowBorrowAmountToken / (TokenLendingPlace.tokenVaultFlow.balance + TokenLendingPlace.FlowBorrowAmountToken) < TokenLendingPlace.optimalUtilizationRate){
            TokenLendingPlace.mFlowInterestRate = TokenLendingPlace.FlowBorrowAmountToken / (TokenLendingPlace.tokenVaultFlow.balance + TokenLendingPlace.FlowBorrowAmountToken) / TokenLendingPlace.optimalUtilizationRate * TokenLendingPlace.optimalBorrowApy
        }else{
            TokenLendingPlace.mFlowInterestRate = ((TokenLendingPlace.FlowBorrowAmountToken / (TokenLendingPlace.tokenVaultFlow.balance + TokenLendingPlace.FlowBorrowAmountToken)) - TokenLendingPlace.optimalUtilizationRate)/(1.0-TokenLendingPlace.optimalUtilizationRate)*(1.0-TokenLendingPlace.optimalUtilizationRate)+TokenLendingPlace.optimalUtilizationRate
        }
      }
      if(TokenLendingPlace.tokenVaultFUSD.balance + TokenLendingPlace.FUSDBorrowAmountToken != 0.0){
        if(TokenLendingPlace.FUSDBorrowAmountToken / (TokenLendingPlace.tokenVaultFUSD.balance + TokenLendingPlace.FUSDBorrowAmountToken) < TokenLendingPlace.optimalUtilizationRate){
            TokenLendingPlace.mFUSDInterestRate = TokenLendingPlace.FUSDBorrowAmountToken / (TokenLendingPlace.tokenVaultFUSD.balance + TokenLendingPlace.FUSDBorrowAmountToken)/ TokenLendingPlace.optimalUtilizationRate*TokenLendingPlace.optimalBorrowApy
        }else{
            TokenLendingPlace.mFUSDInterestRate = ((TokenLendingPlace.FUSDBorrowAmountToken / (TokenLendingPlace.tokenVaultFUSD.balance + TokenLendingPlace.FUSDBorrowAmountToken)) - TokenLendingPlace.optimalUtilizationRate)/(1.0-TokenLendingPlace.optimalUtilizationRate)*(1.0-TokenLendingPlace.optimalUtilizationRate)+TokenLendingPlace.optimalUtilizationRate
        }
      }
      if(TokenLendingPlace.tokenVaultBLT.balance + TokenLendingPlace.BLTBorrowAmountToken != 0.0){
        if(TokenLendingPlace.BLTBorrowAmountToken / (TokenLendingPlace.tokenVaultBLT.balance + TokenLendingPlace.BLTBorrowAmountToken) < TokenLendingPlace.optimalUtilizationRate){
            TokenLendingPlace.mBLTInterestRate = TokenLendingPlace.BLTBorrowAmountToken / (TokenLendingPlace.tokenVaultBLT.balance + TokenLendingPlace.BLTBorrowAmountToken)/ TokenLendingPlace.optimalUtilizationRate*TokenLendingPlace.optimalBorrowApy
        }else{
            TokenLendingPlace.mBLTInterestRate = ((TokenLendingPlace.BLTBorrowAmountToken / (TokenLendingPlace.tokenVaultBLT.balance + TokenLendingPlace.BLTBorrowAmountToken)) - TokenLendingPlace.optimalUtilizationRate)/(1.0-TokenLendingPlace.optimalUtilizationRate)*(1.0-TokenLendingPlace.optimalUtilizationRate)+TokenLendingPlace.optimalUtilizationRate
        }
      }
    
    }

    //TODO, waiting real feed source, and limit certain caller.
    pub fun updatePricefromOracle(_FlowPrice: UFix64, _FUSDPrice: UFix64, _BLTPrice: UFix64){
      self.FlowTokenRealPrice = _FlowPrice
      self.FUSDRealPrice = _FUSDPrice
      self.BLTTokenRealPrice = _BLTPrice
    }

    // LendingCollection
    //
    // Token Collection object 紀錄了用戶的所有數據，用戶透過此 collection 來參與協議
    //
    pub resource TokenLendingCollection: TokenLendingPublic {

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
                TokenLendingPlace.tokenVaultFlow.deposit(from: <- from)
                self.mFlow = self.mFlow + (balance / TokenLendingPlace.mFlowtokenPrice)
            } else if( from.getType() == Type<@FUSD.Vault>()) {
                let balance = from.balance
                TokenLendingPlace.tokenVaultFUSD.deposit(from: <- from)
                self.mFUSD = self.mFUSD + (balance / TokenLendingPlace.mFUSDtokenPrice)
            } else if( from.getType() == Type<@BloctoToken.Vault>()) {
                let balance = from.balance
                TokenLendingPlace.tokenVaultBLT.deposit(from: <- from)
                self.mBLT = self.mBLT + (balance / TokenLendingPlace.mBLTtokenPrice)
            }

            TokenLendingPlace.updatePriceAndInterest()
            //event
        }

        pub fun removeLiquidity(_amount: UFix64, _token: Int): @FungibleToken.Vault {

            if(_token == 0) {
                self.mFlow = self.mFlow - _amount
                let tokenVault <- TokenLendingPlace.tokenVaultFlow.withdraw(amount: (_amount * TokenLendingPlace.mFlowtokenPrice)) 
                TokenLendingPlace.updatePriceAndInterest()
                //event
                 return <- tokenVault
            } else if(_token == 1) {
                self.mFUSD = self.mFUSD - _amount
                let tokenVault <- TokenLendingPlace.tokenVaultFUSD.withdraw(amount: (_amount * TokenLendingPlace.mFUSDtokenPrice)) 
                TokenLendingPlace.updatePriceAndInterest()
                //event
                 return <- tokenVault
            } else {
                self.mBLT = self.mBLT - _amount
                let tokenVault <- TokenLendingPlace.tokenVaultBLT.withdraw(amount: (_amount * TokenLendingPlace.mBLTtokenPrice)) 
                TokenLendingPlace.updatePriceAndInterest()
                //event
                 return <- tokenVault
            }

        }

        pub fun getBorrowingPower(): UFix64 {
            
            //美元計價
            let FlowPower = (self.mFlow - self.myBorrowingmFlow) * TokenLendingPlace.mFlowtokenPrice * TokenLendingPlace.FlowTokenRealPrice
            let FUSDPower = (self.mFUSD - self.myBorrowingmFUSD) * TokenLendingPlace.mFUSDtokenPrice * TokenLendingPlace.FUSDRealPrice 
            let BLTPower = (self.mBLT - self.myBorrowingmBLT) * TokenLendingPlace.mBLTtokenPrice * TokenLendingPlace.BLTTokenRealPrice 

            return FlowPower + FUSDPower + BLTPower
        }

        pub fun getMaxBorrowingPower(): UFix64 {
            
            //美元計價
            let FlowPower = self.mFlow * TokenLendingPlace.mFlowtokenPrice * TokenLendingPlace.FlowTokenRealPrice 
            let FUSDPower = self.mFUSD * TokenLendingPlace.mFUSDtokenPrice * TokenLendingPlace.FUSDRealPrice
            let BLTPower = self.mBLT * TokenLendingPlace.mBLTtokenPrice * TokenLendingPlace.BLTTokenRealPrice

            return FlowPower + FUSDPower + BLTPower
        }
        pub fun getBorrowingNow(): UFix64 {
            
            //美元計價
            let FlowBorrow = self.myBorrowingmFlow * TokenLendingPlace.mFlowtokenPrice * TokenLendingPlace.FlowTokenRealPrice 
            let FUSDBorrow = self.myBorrowingmFUSD * TokenLendingPlace.mFUSDtokenPrice * TokenLendingPlace.FUSDRealPrice
            let BLTBorrow = self.myBorrowingmBLT * TokenLendingPlace.mBLTtokenPrice * TokenLendingPlace.BLTTokenRealPrice

            return FlowBorrow + FUSDBorrow + BLTBorrow
        }

        pub fun borrowFlow(_amount: UFix64): @FungibleToken.Vault {
            pre {
                TokenLendingPlace.tokenVaultFlow.balance - TokenLendingPlace.FlowBorrowAmountToken > _amount: "Amount minted must be greater than zero"
                (self.getBorrowingPower() * 0.6) > (TokenLendingPlace.FlowTokenRealPrice * _amount) : "Amount minted must be greater than zero"
            }

            emit Borrowed(address: self.owner?.address)
            
            let realAmountofToken = _amount * TokenLendingPlace.mFlowtokenPrice
            TokenLendingPlace.FlowBorrowAmountToken = realAmountofToken + TokenLendingPlace.FlowBorrowAmountToken

            self.myBorrowingmFlow = _amount + self.myBorrowingmFlow

            let token1Vault <- TokenLendingPlace.tokenVaultFlow.withdraw(amount: realAmountofToken)
            TokenLendingPlace.updatePriceAndInterest()
            return <- token1Vault
        }

        pub fun borrowFUSD(_amount: UFix64): @FungibleToken.Vault {
            pre {
                TokenLendingPlace.tokenVaultFUSD.balance - TokenLendingPlace.FUSDBorrowAmountToken > _amount: "Amount minted must be greater than zero"
                (self.getBorrowingPower() * 0.6) > (TokenLendingPlace.FUSDRealPrice * _amount) : "Amount minted must be greater than zero"
            }

            emit Borrowed(address: self.owner?.address)
            
            let realAmountofToken = _amount * TokenLendingPlace.mFUSDtokenPrice
            TokenLendingPlace.FUSDBorrowAmountToken = realAmountofToken + TokenLendingPlace.FUSDBorrowAmountToken

            self.myBorrowingmFUSD = _amount + self.myBorrowingmFUSD

            let token1Vault <- TokenLendingPlace.tokenVaultFUSD.withdraw(amount: realAmountofToken)
            TokenLendingPlace.updatePriceAndInterest()
            return <- token1Vault
        }

        pub fun borrowBLT(_amount: UFix64): @FungibleToken.Vault {
            pre {
                TokenLendingPlace.tokenVaultBLT.balance - TokenLendingPlace.BLTBorrowAmountToken > _amount: "Amount minted must be greater than zero"
                (self.getBorrowingPower() * 0.6) > (TokenLendingPlace.BLTTokenRealPrice * _amount) : "Amount minted must be greater than zero"
            }

            emit Borrowed(address: self.owner?.address)
            

            let realAmountofToken = _amount * TokenLendingPlace.mBLTtokenPrice
            TokenLendingPlace.BLTBorrowAmountToken = realAmountofToken + TokenLendingPlace.BLTBorrowAmountToken

            self.myBorrowingmBLT = _amount + self.myBorrowingmBLT

            let token1Vault <- TokenLendingPlace.tokenVaultBLT.withdraw(amount: realAmountofToken)
            TokenLendingPlace.updatePriceAndInterest()
            return <- token1Vault
        }

        //Repay
        pub fun repayFlow(from: @FlowToken.Vault){
            //unlock the borrowing power

            TokenLendingPlace.FlowBorrowAmountToken = TokenLendingPlace.FlowBorrowAmountToken - from.balance
            self.myBorrowingmFlow = self.myBorrowingmFlow - (from.balance / TokenLendingPlace.mFlowtokenPrice)

            TokenLendingPlace.tokenVaultFlow.deposit(from: <- from )
            TokenLendingPlace.updatePriceAndInterest()
        }

        pub fun repayFUSD(from: @FUSD.Vault){
            //unlock the borrowing power


            TokenLendingPlace.FUSDBorrowAmountToken = TokenLendingPlace.FUSDBorrowAmountToken - from.balance
            self.myBorrowingmFUSD = self.myBorrowingmFUSD - (from.balance / TokenLendingPlace.mFUSDtokenPrice)

            TokenLendingPlace.tokenVaultFUSD.deposit(from: <- from )
            TokenLendingPlace.updatePriceAndInterest()
        }

        pub fun repayBLT(from: @BloctoToken.Vault){
            //unlock the borrowing power
            TokenLendingPlace.BLTBorrowAmountToken = TokenLendingPlace.BLTBorrowAmountToken - from.balance
            self.myBorrowingmBLT = self.myBorrowingmBLT - (from.balance / TokenLendingPlace.mBLTtokenPrice)

            TokenLendingPlace.tokenVaultBLT.deposit(from: <- from )
            TokenLendingPlace.updatePriceAndInterest()
        }

        pub fun liquidateFlow(from: @FungibleToken.Vault, liquidatorVault: &TokenLendingCollection){
            
            //flow in flow out
            if(from.getType() == Type<@FlowToken.Vault>()) {
                self.myBorrowingmFlow = self.myBorrowingmFlow - (from.balance / TokenLendingPlace.mFlowtokenPrice)

                let repaymoney = from.balance * 1.05

                liquidatorVault.depositemFlow(from:(repaymoney / TokenLendingPlace.mFlowtokenPrice))

                TokenLendingPlace.tokenVaultFlow.deposit(from: <- from)

                self.mFlow = self.mFlow - (repaymoney / TokenLendingPlace.mFlowtokenPrice)

                //let token1Vault <- TokenLendingPlace.tokenVaultFlow.withdraw(amount: repaymoney)
                //return <- token1Vault
            } else if( from.getType() == Type<@FUSD.Vault>()) 
            {
                TokenLendingPlace.FUSDBorrowAmountToken = TokenLendingPlace.FUSDBorrowAmountToken - from.balance
                self.myBorrowingmFUSD = self.myBorrowingmFUSD - (from.balance / TokenLendingPlace.mFUSDtokenPrice)
                
                let repaymoney = from.balance * 1.05 / TokenLendingPlace.FlowTokenRealPrice

                liquidatorVault.depositemFUSD(from:(repaymoney / TokenLendingPlace.mFUSDtokenPrice))

                TokenLendingPlace.tokenVaultFUSD.deposit(from: <- from)

                self.mFlow = self.mFlow - (repaymoney / TokenLendingPlace.mFlowtokenPrice)

                //let tokenVault <- TokenLendingPlace.tokenVaultFlow.withdraw(amount: repaymoney)
                //return <- tokenVault
            } else if( from.getType() == Type<@BloctoToken.Vault>())  {
                 TokenLendingPlace.BLTBorrowAmountToken = TokenLendingPlace.BLTBorrowAmountToken - from.balance
                self.myBorrowingmBLT = self.myBorrowingmBLT - (from.balance / TokenLendingPlace.mBLTtokenPrice)
                
                let repaymoney = from.balance * 1.05 / TokenLendingPlace.BLTTokenRealPrice

                liquidatorVault.depositemBLT(from:(repaymoney / TokenLendingPlace.mBLTtokenPrice))

                TokenLendingPlace.tokenVaultBLT.deposit(from: <- from)

                self.mBLT = self.mBLT - (repaymoney / TokenLendingPlace.mBLTtokenPrice)
            }
            TokenLendingPlace.updatePriceAndInterest()
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
    pub fun createTokenLendingCollection(): @TokenLendingCollection {
        return <- create TokenLendingCollection()
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
        self.CollectionStoragePath = /storage/GaiaCollection001
        self.CollectionPublicPath = /public/GaiaCollection001
  }
}
 
