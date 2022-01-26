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

    //協議中的代幣皆採用 mToken 為代表，mToken 價格僅會往上升，而不會下降。
    pub var mFlowBorrowingtokenPrice: UFix64 
    pub var mFUSDBorrowingtokenPrice: UFix64
    pub var mBLTBorrowingtokenPrice: UFix64

    //協議中各項token的真實價格，由預言機與Admin進行更新
    pub var FlowTokenRealPrice: UFix64
    pub var FUSDRealPrice: UFix64
    pub var BLTTokenRealPrice: UFix64
    

    //協議中mtoken更新的斜率
    pub var mFlowInterestRate: UFix64
    pub var mFUSDInterestRate: UFix64 
    pub var mBLTInterestRate: UFix64 

    //協議中mtoken更新的斜率
    pub var mFlowBorrowingInterestRate: UFix64
    pub var mFUSDBorrowingInterestRate: UFix64 
    pub var mBLTBorrowingInterestRate: UFix64 

    //協議中mToken最後更新的時間
    pub var finalTimestamp: UFix64

    //協議中目前代幣被借出的總數量，此金額將影響利率的計算
    pub var mFlowBorrowingAmountToken: UFix64
    pub var mFUSDBorrowingAmountToken: UFix64
    pub var mBLTBorrowingAmountToken: UFix64

    //協議中限制代幣存放與領出的數量
    pub var depositeLimitFLOWToken: UFix64
    pub var depositeLimitFUSD: UFix64
    pub var depositeLimitBLTToken: UFix64

    //協議中各項利率優化的參與指標
    pub var optimalUtilizationRate: UFix64
    pub var optimalBorrowApy: UFix64
    pub var loanToValueRatio: UFix64

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    //flow總共借幾％
    pub fun getFlowBorrowPercent(): UFix64 {
        if(TokenLendingPlace.tokenVaultFlow.balance + TokenLendingPlace.mFlowBorrowingAmountToken * TokenLendingPlace.getmFlowBorrowingtokenPrice() != 0.0){
            return (TokenLendingPlace.mFlowBorrowingAmountToken * TokenLendingPlace.getmFlowBorrowingtokenPrice()) / (TokenLendingPlace.tokenVaultFlow.balance + TokenLendingPlace.mFlowBorrowingAmountToken * TokenLendingPlace.getmFlowBorrowingtokenPrice())
        }else {
            return 0.0
        }
    }
    //fusd總共借幾％
    pub fun getFUSDBorrowPercent(): UFix64 {
        if(TokenLendingPlace.tokenVaultFUSD.balance + TokenLendingPlace.mFUSDBorrowingAmountToken * TokenLendingPlace.getmFUSDBorrowingtokenPrice() != 0.0){
            return (TokenLendingPlace.mFUSDBorrowingAmountToken * TokenLendingPlace.getmFUSDBorrowingtokenPrice()) / (TokenLendingPlace.tokenVaultFUSD.balance + TokenLendingPlace.mFUSDBorrowingAmountToken * TokenLendingPlace.getmFUSDBorrowingtokenPrice())
        }else{
            return 0.0
        }
    }
    //blt總共借幾％
    pub fun getBltBorrowPercent(): UFix64 {
        if(TokenLendingPlace.tokenVaultBLT.balance + TokenLendingPlace.mBLTBorrowingAmountToken * TokenLendingPlace.getmBLTBorrowingtokenPrice() != 0.0){
            return (TokenLendingPlace.mBLTBorrowingAmountToken * TokenLendingPlace.getmBLTBorrowingtokenPrice()) / (TokenLendingPlace.tokenVaultBLT.balance + TokenLendingPlace.mBLTBorrowingAmountToken * TokenLendingPlace.getmBLTBorrowingtokenPrice())
        }else{
            return 0.0
        }
    }
    //拿到當下的mFlowBorrowingtokenPrice
    pub fun getmFlowBorrowingtokenPrice(): UFix64{
        let delta = getCurrentBlock().timestamp - TokenLendingPlace.finalTimestamp
        return TokenLendingPlace.mFlowBorrowingtokenPrice + delta * TokenLendingPlace.mFlowBorrowingInterestRate
    }
    //拿到當下的mFUSDBorrowingtokenPrice
    pub fun getmFUSDBorrowingtokenPrice(): UFix64{
        let delta = getCurrentBlock().timestamp - TokenLendingPlace.finalTimestamp
        return TokenLendingPlace.mFUSDBorrowingtokenPrice + delta * TokenLendingPlace.mFUSDBorrowingInterestRate
    }
    //拿到當下的mBLTBorrowingtokenPrice
    pub fun getmBLTBorrowingtokenPrice(): UFix64{
        let delta = getCurrentBlock().timestamp - TokenLendingPlace.finalTimestamp
        return TokenLendingPlace.mBLTBorrowingtokenPrice + delta * TokenLendingPlace.mBLTBorrowingInterestRate
    }
     //拿到當下的mFlowtokenPrice
     pub fun getmFlowtokenPrice(): UFix64{
        let delta = getCurrentBlock().timestamp - TokenLendingPlace.finalTimestamp
        return TokenLendingPlace.mFlowtokenPrice + delta * TokenLendingPlace.mFlowInterestRate
    }
     //拿到當下的mFUSDtokenPrice
    pub fun getmFUSDtokenPrice(): UFix64{
        let delta = getCurrentBlock().timestamp - TokenLendingPlace.finalTimestamp
        return TokenLendingPlace.mFUSDtokenPrice + delta * TokenLendingPlace.mFUSDInterestRate
    }
    //拿到當下的mBLTtokenPrice
    pub fun getmBLTtokenPrice(): UFix64{
        let delta = getCurrentBlock().timestamp - TokenLendingPlace.finalTimestamp
        return TokenLendingPlace.mBLTtokenPrice + delta * TokenLendingPlace.mBLTInterestRate
    }
    //拿TotalSupply
    pub fun getTotalsupply(): {String: UFix64} {
            return {"flowTotalSupply":TokenLendingPlace.tokenVaultFlow.balance + TokenLendingPlace.mFlowBorrowingAmountToken * TokenLendingPlace.getmFlowBorrowingtokenPrice(), "fusdTotalSupply": TokenLendingPlace.tokenVaultFUSD.balance + TokenLendingPlace.mFUSDBorrowingAmountToken * TokenLendingPlace.getmFUSDBorrowingtokenPrice(), "bltTotalSupply":TokenLendingPlace.tokenVaultBLT.balance + TokenLendingPlace.mBLTBorrowingAmountToken * TokenLendingPlace.getmBLTBorrowingtokenPrice()}
    }
    //拿DepositLimit
    pub fun getDepositLimit(): {String: UFix64} {
            return {"flowDepositLimit":TokenLendingPlace.depositeLimitFLOWToken,"fusdDepositLimit": TokenLendingPlace.depositeLimitFUSD, "bltDepositLimit":TokenLendingPlace.depositeLimitBLTToken}
    }
    //拿total borrow
    pub fun getTotalBorrow(): {String: UFix64} {
            return {"flowTotalBorrow":TokenLendingPlace.mFlowBorrowingAmountToken * TokenLendingPlace.getmFlowBorrowingtokenPrice(),"fusdTotalBorrow": TokenLendingPlace.mFUSDBorrowingAmountToken * TokenLendingPlace.getmFUSDBorrowingtokenPrice(), "bltTotalBorrow":TokenLendingPlace.mBLTBorrowingAmountToken * TokenLendingPlace.getmBLTBorrowingtokenPrice()}
    }
    //拿token real price
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

      TokenLendingPlace.mFlowBorrowingtokenPrice = TokenLendingPlace.mFlowBorrowingtokenPrice + (delta * TokenLendingPlace.mFlowBorrowingInterestRate /( 365.0 * 24.0 * 60.0 * 60.0))
      TokenLendingPlace.mFUSDBorrowingtokenPrice = TokenLendingPlace.mFUSDBorrowingtokenPrice + (delta * TokenLendingPlace.mFUSDBorrowingInterestRate /( 365.0 * 24.0 * 60.0 * 60.0))
      TokenLendingPlace.mBLTBorrowingtokenPrice = TokenLendingPlace.mBLTBorrowingtokenPrice + (delta * TokenLendingPlace.mBLTBorrowingInterestRate /( 365.0 * 24.0 * 60.0 * 60.0))
      //TokenLendingPlace.finalTimestamp = getCurrentBlock().timestamp
      TokenLendingPlace.finalTimestamp = 0.0

      //update interestRate
      if(TokenLendingPlace.tokenVaultFlow.balance + TokenLendingPlace.mFlowBorrowingAmountToken * TokenLendingPlace.getmFlowBorrowingtokenPrice() != 0.0){
        if(TokenLendingPlace.mFlowBorrowingAmountToken / (TokenLendingPlace.tokenVaultFlow.balance + TokenLendingPlace.mFlowBorrowingAmountToken * TokenLendingPlace.getmFlowBorrowingtokenPrice()) < TokenLendingPlace.optimalUtilizationRate){
            TokenLendingPlace.mFlowBorrowingInterestRate = TokenLendingPlace.mFlowBorrowingAmountToken / (TokenLendingPlace.tokenVaultFlow.balance + TokenLendingPlace.mFlowBorrowingAmountToken * TokenLendingPlace.getmFlowBorrowingtokenPrice()) / TokenLendingPlace.optimalUtilizationRate * TokenLendingPlace.optimalBorrowApy
        }else{
            TokenLendingPlace.mFlowBorrowingInterestRate = ((TokenLendingPlace.mFlowBorrowingAmountToken / (TokenLendingPlace.tokenVaultFlow.balance + TokenLendingPlace.mFlowBorrowingAmountToken * TokenLendingPlace.getmFlowBorrowingtokenPrice())) - TokenLendingPlace.optimalUtilizationRate)/(1.0-TokenLendingPlace.optimalUtilizationRate)*(1.0-TokenLendingPlace.optimalUtilizationRate)+TokenLendingPlace.optimalUtilizationRate
        }
        TokenLendingPlace.mFlowInterestRate = TokenLendingPlace.mFlowBorrowingInterestRate * TokenLendingPlace.getFlowBorrowPercent()
      }
      if(TokenLendingPlace.tokenVaultFUSD.balance + TokenLendingPlace.mFUSDBorrowingAmountToken * TokenLendingPlace.getmFUSDBorrowingtokenPrice() != 0.0){
        if(TokenLendingPlace.mFUSDBorrowingAmountToken / (TokenLendingPlace.tokenVaultFUSD.balance + TokenLendingPlace.mFUSDBorrowingAmountToken * TokenLendingPlace.getmFUSDBorrowingtokenPrice()) < TokenLendingPlace.optimalUtilizationRate){
            TokenLendingPlace.mFUSDBorrowingInterestRate = TokenLendingPlace.mFUSDBorrowingAmountToken / (TokenLendingPlace.tokenVaultFUSD.balance + TokenLendingPlace.mFUSDBorrowingAmountToken * TokenLendingPlace.getmFUSDBorrowingtokenPrice())/ TokenLendingPlace.optimalUtilizationRate*TokenLendingPlace.optimalBorrowApy
        }else{
            TokenLendingPlace.mFUSDBorrowingInterestRate = ((TokenLendingPlace.mFUSDBorrowingAmountToken / (TokenLendingPlace.tokenVaultFUSD.balance + TokenLendingPlace.mFUSDBorrowingAmountToken * TokenLendingPlace.getmFUSDBorrowingtokenPrice())) - TokenLendingPlace.optimalUtilizationRate)/(1.0-TokenLendingPlace.optimalUtilizationRate)*(1.0-TokenLendingPlace.optimalUtilizationRate)+TokenLendingPlace.optimalUtilizationRate
        }
        TokenLendingPlace.mFUSDInterestRate = TokenLendingPlace.mFUSDBorrowingInterestRate * TokenLendingPlace.getFUSDBorrowPercent()
      }
      if(TokenLendingPlace.tokenVaultBLT.balance + TokenLendingPlace.mBLTBorrowingAmountToken * TokenLendingPlace.getmBLTBorrowingtokenPrice() != 0.0){
        if(TokenLendingPlace.mBLTBorrowingAmountToken / (TokenLendingPlace.tokenVaultBLT.balance + TokenLendingPlace.mBLTBorrowingAmountToken * TokenLendingPlace.getmBLTBorrowingtokenPrice()) < TokenLendingPlace.optimalUtilizationRate){
            TokenLendingPlace.mBLTBorrowingInterestRate = TokenLendingPlace.mBLTBorrowingAmountToken / (TokenLendingPlace.tokenVaultBLT.balance + TokenLendingPlace.mBLTBorrowingAmountToken * TokenLendingPlace.getmBLTBorrowingtokenPrice())/ TokenLendingPlace.optimalUtilizationRate*TokenLendingPlace.optimalBorrowApy
        }else{
            TokenLendingPlace.mBLTBorrowingInterestRate = ((TokenLendingPlace.mBLTBorrowingAmountToken / (TokenLendingPlace.tokenVaultBLT.balance + TokenLendingPlace.mBLTBorrowingAmountToken * TokenLendingPlace.getmBLTBorrowingtokenPrice())) - TokenLendingPlace.optimalUtilizationRate)/(1.0-TokenLendingPlace.optimalUtilizationRate)*(1.0-TokenLendingPlace.optimalUtilizationRate)+TokenLendingPlace.optimalUtilizationRate
        }
        TokenLendingPlace.mBLTInterestRate = TokenLendingPlace.mBLTBorrowingInterestRate * TokenLendingPlace.getBltBorrowPercent()
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
                self.mFlow = self.mFlow + (balance / TokenLendingPlace.getmFlowtokenPrice())
            } else if( from.getType() == Type<@FUSD.Vault>()) {
                let balance = from.balance
                TokenLendingPlace.tokenVaultFUSD.deposit(from: <- from)
                self.mFUSD = self.mFUSD + (balance / TokenLendingPlace.getmFUSDtokenPrice())
            } else if( from.getType() == Type<@BloctoToken.Vault>()) {
                let balance = from.balance
                TokenLendingPlace.tokenVaultBLT.deposit(from: <- from)
                self.mBLT = self.mBLT + (balance / TokenLendingPlace.getmBLTtokenPrice())
            }

            TokenLendingPlace.updatePriceAndInterest()
            //event
        }

        pub fun removeLiquidity(_amount: UFix64, _token: Int): @FungibleToken.Vault {

            if(_token == 0) {
                let mFlowAmount = _amount / TokenLendingPlace.getmFlowtokenPrice()
                self.mFlow = self.mFlow - mFlowAmount
                let tokenVault <- TokenLendingPlace.tokenVaultFlow.withdraw(amount: _amount) 
                TokenLendingPlace.updatePriceAndInterest()
                self.checkBorrowValid()
                //event
                 return <- tokenVault
            } else if(_token == 1) {
                let mFUSDAmount = _amount / TokenLendingPlace.getmFUSDtokenPrice()
                self.mFUSD = self.mFUSD - mFUSDAmount
                let tokenVault <- TokenLendingPlace.tokenVaultFUSD.withdraw(amount: _amount) 
                TokenLendingPlace.updatePriceAndInterest()
                self.checkBorrowValid()
                //event
                 return <- tokenVault
            } else {
                let mBLTAmount = _amount / TokenLendingPlace.getmBLTtokenPrice()
                self.mBLT = self.mBLT - mBLTAmount
                let tokenVault <- TokenLendingPlace.tokenVaultBLT.withdraw(amount: _amount) 
                TokenLendingPlace.updatePriceAndInterest()
                self.checkBorrowValid()
                //event
                 return <- tokenVault
            }

        }

        //查net value
        pub fun getBorrowingPower(): UFix64 {
            
            //美元計價
            let FlowPower = (self.mFlow * TokenLendingPlace.getmFlowtokenPrice() - self.myBorrowingmFlow * TokenLendingPlace.getmFlowBorrowingtokenPrice()) * TokenLendingPlace.FlowTokenRealPrice
            let FUSDPower = (self.mFUSD * TokenLendingPlace.getmFUSDtokenPrice() - self.myBorrowingmFUSD * TokenLendingPlace.getmFUSDBorrowingtokenPrice()) * TokenLendingPlace.FUSDRealPrice 
            let BLTPower = (self.mBLT * TokenLendingPlace.getmBLTtokenPrice() - self.myBorrowingmBLT * TokenLendingPlace.getmFUSDBorrowingtokenPrice()) * TokenLendingPlace.BLTTokenRealPrice 

            return FlowPower + FUSDPower + BLTPower
        }
        //查supply balance
        pub fun getMaxBorrowingPower(): UFix64 {
            
            //美元計價
            let FlowPower = self.mFlow * TokenLendingPlace.getmFlowtokenPrice() * TokenLendingPlace.FlowTokenRealPrice 
            let FUSDPower = self.mFUSD * TokenLendingPlace.getmFUSDtokenPrice() * TokenLendingPlace.FUSDRealPrice
            let BLTPower = self.mBLT * TokenLendingPlace.getmBLTtokenPrice() * TokenLendingPlace.BLTTokenRealPrice

            return FlowPower + FUSDPower + BLTPower
        }
        //查borrow balance
        pub fun getBorrowingNow(): UFix64 {
            
            //美元計價
            let FlowBorrow = self.myBorrowingmFlow * TokenLendingPlace.getmFlowBorrowingtokenPrice() * TokenLendingPlace.FlowTokenRealPrice 
            let FUSDBorrow = self.myBorrowingmFUSD * TokenLendingPlace.getmFUSDBorrowingtokenPrice() * TokenLendingPlace.FUSDRealPrice
            let BLTBorrow = self.myBorrowingmBLT * TokenLendingPlace.getmBLTBorrowingtokenPrice() * TokenLendingPlace.BLTTokenRealPrice

            return FlowBorrow + FUSDBorrow + BLTBorrow
        }

        pub fun borrowFlow(_amount: UFix64): @FungibleToken.Vault {
            pre {
                TokenLendingPlace.tokenVaultFlow.balance - _amount >= 0.0: "Not enough Flow to borrow"
            }

            emit Borrowed(address: self.owner?.address)
            
            let realAmountmToken = _amount / TokenLendingPlace.getmFlowBorrowingtokenPrice()
            TokenLendingPlace.mFlowBorrowingAmountToken = realAmountmToken + TokenLendingPlace.mFlowBorrowingAmountToken

            self.myBorrowingmFlow = realAmountmToken + self.myBorrowingmFlow

            let token1Vault <- TokenLendingPlace.tokenVaultFlow.withdraw(amount: _amount)
            TokenLendingPlace.updatePriceAndInterest()
            self.checkBorrowValid()
            return <- token1Vault
        }

        pub fun borrowFUSD(_amount: UFix64): @FungibleToken.Vault {
            pre {
                TokenLendingPlace.tokenVaultFUSD.balance - _amount >= 0.0: "Not enough FUSD to borrow"
                }

            emit Borrowed(address: self.owner?.address)
            
            let realAmountmToken = _amount / TokenLendingPlace.getmFUSDBorrowingtokenPrice()
            TokenLendingPlace.mFUSDBorrowingAmountToken = realAmountmToken + TokenLendingPlace.mFUSDBorrowingAmountToken

            self.myBorrowingmFUSD = realAmountmToken + self.myBorrowingmFUSD

            let token1Vault <- TokenLendingPlace.tokenVaultFUSD.withdraw(amount: _amount)
            TokenLendingPlace.updatePriceAndInterest()
            self.checkBorrowValid()
            return <- token1Vault
        }

        pub fun borrowBLT(_amount: UFix64): @FungibleToken.Vault {
            pre {
                TokenLendingPlace.tokenVaultBLT.balance - _amount >= 0.0: "Not enough BLT to borrow"
                }

            emit Borrowed(address: self.owner?.address)
            

            let realAmountmToken = _amount / TokenLendingPlace.getmBLTBorrowingtokenPrice()
            TokenLendingPlace.mBLTBorrowingAmountToken = realAmountmToken + TokenLendingPlace.mBLTBorrowingAmountToken

            self.myBorrowingmBLT = realAmountmToken + self.myBorrowingmBLT

            let token1Vault <- TokenLendingPlace.tokenVaultBLT.withdraw(amount: _amount)
            TokenLendingPlace.updatePriceAndInterest()
            self.checkBorrowValid()
            return <- token1Vault
        }

        //Repay
        pub fun repayFlow(from: @FlowToken.Vault){
            //unlock the borrowing power

            TokenLendingPlace.mFlowBorrowingAmountToken = TokenLendingPlace.mFlowBorrowingAmountToken - from.balance / TokenLendingPlace.getmFlowBorrowingtokenPrice()
            self.myBorrowingmFlow = self.myBorrowingmFlow - from.balance / TokenLendingPlace.getmFlowBorrowingtokenPrice()

            TokenLendingPlace.tokenVaultFlow.deposit(from: <- from )
            TokenLendingPlace.updatePriceAndInterest()
        }

        pub fun repayFUSD(from: @FUSD.Vault){
            //unlock the borrowing power


            TokenLendingPlace.mFUSDBorrowingAmountToken = TokenLendingPlace.mFUSDBorrowingAmountToken - from.balance / TokenLendingPlace.getmFUSDBorrowingtokenPrice()
            self.myBorrowingmFUSD = self.myBorrowingmFUSD - from.balance / TokenLendingPlace.getmFUSDBorrowingtokenPrice()

            TokenLendingPlace.tokenVaultFUSD.deposit(from: <- from )
            TokenLendingPlace.updatePriceAndInterest()
        }

        pub fun repayBLT(from: @BloctoToken.Vault){
            //unlock the borrowing power
            TokenLendingPlace.mBLTBorrowingAmountToken = TokenLendingPlace.mBLTBorrowingAmountToken - from.balance / TokenLendingPlace.getmBLTBorrowingtokenPrice()
            self.myBorrowingmBLT = self.myBorrowingmBLT -  from.balance / TokenLendingPlace.getmBLTBorrowingtokenPrice()

            TokenLendingPlace.tokenVaultBLT.deposit(from: <- from )
            TokenLendingPlace.updatePriceAndInterest()
        }

        pub fun checkBorrowValid() {
            assert(self.getBorrowingNow()/self.getMaxBorrowingPower() < TokenLendingPlace.loanToValueRatio , message: "greater then loanToValueRatio")
        }
        pub fun checkLiquidValid() {
            assert(self.getBorrowingNow()/self.getMaxBorrowingPower() < TokenLendingPlace.optimalUtilizationRate , message: "greater then optimalUtilizationRate")
        }

        pub fun liquidateFlow(from: @FungibleToken.Vault, liquidatorVault: &TokenLendingCollection){
            self.checkLiquidValid()
            //flow in flow out
            if(from.getType() == Type<@FlowToken.Vault>()) {
                self.myBorrowingmFlow = self.myBorrowingmFlow - (from.balance / TokenLendingPlace.getmFlowBorrowingtokenPrice())

                let repaymoney = from.balance

                liquidatorVault.depositemFlow(from:(repaymoney * TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.getmFlowtokenPrice()))

                TokenLendingPlace.tokenVaultFlow.deposit(from: <- from)

                self.mFlow = self.mFlow - (repaymoney / TokenLendingPlace.getmFlowtokenPrice())

            } else if( from.getType() == Type<@FUSD.Vault>()) 
            {
                //FUSD in Flow out
                self.myBorrowingmFUSD = self.myBorrowingmFUSD - (from.balance / TokenLendingPlace.getmFUSDBorrowingtokenPrice())

                let repaymoney = from.balance

                liquidatorVault.depositemFlow(from:(repaymoney * TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.getmFlowtokenPrice()))

                TokenLendingPlace.tokenVaultFUSD.deposit(from: <- from)

                self.mFlow = self.mFlow - (repaymoney * TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.getmFlowtokenPrice())
            } else if( from.getType() == Type<@BloctoToken.Vault>())  {
                 //BLT in Flow out
                self.myBorrowingmBLT = self.myBorrowingmBLT - (from.balance / TokenLendingPlace.getmBLTBorrowingtokenPrice())

                let repaymoney = from.balance

                liquidatorVault.depositemFlow(from:(repaymoney * TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.getmFlowtokenPrice()))

                TokenLendingPlace.tokenVaultBLT.deposit(from: <- from)

                self.mFlow = self.mFlow - (repaymoney * TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.getmFlowtokenPrice())
            }
            TokenLendingPlace.updatePriceAndInterest()
        }
        pub fun liquidateFUSD(from: @FungibleToken.Vault, liquidatorVault: &TokenLendingCollection){
            self.checkLiquidValid()
            //flow in FUSD out
            if(from.getType() == Type<@FlowToken.Vault>()) {
                self.myBorrowingmFlow = self.myBorrowingmFlow - (from.balance / TokenLendingPlace.getmFlowBorrowingtokenPrice())

                let repaymoney = from.balance

                liquidatorVault.depositemFUSD(from:(repaymoney * TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.getmFUSDtokenPrice()))

                TokenLendingPlace.tokenVaultFlow.deposit(from: <- from)

                self.mFUSD = self.mFUSD - (repaymoney * TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.getmFUSDtokenPrice())

            } else if( from.getType() == Type<@FUSD.Vault>()) 
            {
                //FUSD in FUSD out
                self.myBorrowingmFUSD = self.myBorrowingmFUSD - (from.balance / TokenLendingPlace.getmFUSDBorrowingtokenPrice())

                let repaymoney = from.balance

                liquidatorVault.depositemFUSD(from:(repaymoney * TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.getmFUSDtokenPrice()))

                TokenLendingPlace.tokenVaultFUSD.deposit(from: <- from)

                self.mFUSD = self.mFUSD - (repaymoney * TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.getmFUSDtokenPrice())
            } else if( from.getType() == Type<@BloctoToken.Vault>())  {
                 //BLT in FUSD out
                self.myBorrowingmBLT = self.myBorrowingmBLT - (from.balance / TokenLendingPlace.getmBLTBorrowingtokenPrice())

                let repaymoney = from.balance

                liquidatorVault.depositemFUSD(from:(repaymoney * TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.getmFUSDtokenPrice()))

                TokenLendingPlace.tokenVaultBLT.deposit(from: <- from)

                self.mFUSD = self.mFUSD - (repaymoney * TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.getmFUSDtokenPrice())
            }
            TokenLendingPlace.updatePriceAndInterest()
        }
        pub fun liquidateBLT(from: @FungibleToken.Vault, liquidatorVault: &TokenLendingCollection){
            self.checkLiquidValid()
            //flow in BLT out
            if(from.getType() == Type<@FlowToken.Vault>()) {
                self.myBorrowingmFlow = self.myBorrowingmFlow - (from.balance / TokenLendingPlace.getmFlowBorrowingtokenPrice())

                let repaymoney = from.balance

                liquidatorVault.depositemBLT(from:(repaymoney * TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.getmBLTtokenPrice()))

                TokenLendingPlace.tokenVaultFlow.deposit(from: <- from)

                self.mBLT = self.mBLT - (repaymoney * TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.getmBLTtokenPrice())

            } else if( from.getType() == Type<@FUSD.Vault>()) 
            {
                //FUSD in BLT out
                self.myBorrowingmFUSD = self.myBorrowingmFUSD - (from.balance / TokenLendingPlace.getmFUSDBorrowingtokenPrice())

                let repaymoney = from.balance

                liquidatorVault.depositemBLT(from:(repaymoney * TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.getmBLTtokenPrice()))

                TokenLendingPlace.tokenVaultFUSD.deposit(from: <- from)

                self.mBLT = self.mBLT - (repaymoney * TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.getmBLTtokenPrice())
            } else if( from.getType() == Type<@BloctoToken.Vault>())  {
                 //BLT in BLT out
                self.myBorrowingmBLT = self.myBorrowingmBLT - (from.balance / TokenLendingPlace.getmBLTBorrowingtokenPrice())

                let repaymoney = from.balance

                liquidatorVault.depositemBLT(from:(repaymoney * TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.getmBLTtokenPrice()))

                TokenLendingPlace.tokenVaultBLT.deposit(from: <- from)

                self.mBLT = self.mBLT - (repaymoney * TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.getmBLTtokenPrice())
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
        self.mFlowBorrowingInterestRate = 0.0
        self.mFUSDBorrowingInterestRate = 0.0
        self.mBLTBorrowingInterestRate = 0.0
        self.mFlowtokenPrice = 1.0
        self.mFUSDtokenPrice = 1.0
        self.mBLTtokenPrice = 1.0
        self.mFlowBorrowingtokenPrice = 1.0
        self.mFUSDBorrowingtokenPrice = 1.0
        self.mBLTBorrowingtokenPrice = 1.0

        self.FlowTokenRealPrice = 10.0
        self.FUSDRealPrice = 1.0
        self.BLTTokenRealPrice = 4.0
        self.finalTimestamp = 0.0 //getCurrentBlock().height

        self.mFlowBorrowingAmountToken = 0.0
        self.mFUSDBorrowingAmountToken = 0.0
        self.mBLTBorrowingAmountToken = 0.0

        self.depositeLimitFLOWToken = 100000.0
        self.depositeLimitFUSD = 1000000.0
        self.depositeLimitBLTToken = 1000000.0

        self.optimalUtilizationRate = 0.8
        self.optimalBorrowApy = 0.08
        self.loanToValueRatio = 0.7
        self.CollectionStoragePath = /storage/TokenLendingPlace001
        self.CollectionPublicPath = /public/TokenLendingPlace001
  }
}
 
