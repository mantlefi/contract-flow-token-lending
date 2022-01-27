import FungibleToken from 0x01
import FlowToken from 0x02
import FUSD from 0x03
import BloctoToken from 0x05

pub contract TokenLendingPlace {

    //Event emitted when user deposit token and mint mToken
    pub event Mint(minter: Address?, kind: Type, mintAmount: UFix64, mintTokens: UFix64)

    //Event emitted when user redeem mToken and withdraw token
    pub event Redeem(redeemer: Address?, kind: Type, redeemAmount: UFix64, redeemTokens: UFix64)

    //Event emitted when user borrow the token
    pub event Borrow(borrower: Address?, kind: Type, borrowAmount: UFix64)

    //Event emitted when user repay the token
    pub event RepayBorrow(payer: Address?, borrower: Address?, kind: Type, repayAmount: UFix64)

    //Event emitted when user liquidate the token
    pub event LiquidateBorrow(liquidator: Address?, borrower: Address?, kindRepay: Type, kindSeize: Type, repayAmount: UFix64, seizeTokens: UFix64)

    //here is where store the token
    access(contract) let TokenVaultFlow: @FlowToken.Vault
    access(contract) let TokenVaultFUSD: @FUSD.Vault
    access(contract) let TokenVaultBLT: @BloctoToken.Vault

    //The tokens be minted in the protocol are all represented by mToken, and the price of mToken will only rise, not fall.
    //user will mint mToken when deposit
    pub var mFlowtokenPrice: UFix64 
    pub var mFUSDtokenPrice: UFix64
    pub var mBLTtokenPrice: UFix64

    //user will mint mBorrowingToken when borrow
    pub var mFlowBorrowingtokenPrice: UFix64 
    pub var mFUSDBorrowingtokenPrice: UFix64
    pub var mBLTBorrowingtokenPrice: UFix64

    //the token real price
    pub var FlowTokenRealPrice: UFix64
    pub var FUSDRealPrice: UFix64
    pub var BLTTokenRealPrice: UFix64
    

    //apr of each token deposit
    pub var mFlowInterestRate: UFix64
    pub var mFUSDInterestRate: UFix64 
    pub var mBLTInterestRate: UFix64 

    //apr of each token borrow
    pub var mFlowBorrowingInterestRate: UFix64
    pub var mFUSDBorrowingInterestRate: UFix64 
    pub var mBLTBorrowingInterestRate: UFix64 

    //last interest update timestamp
    pub var finalTimestamp: UFix64

    //The total amount of tokens being lent in the protocol, this amount will affect the calculation of the interest
    pub var mFlowBorrowingAmountToken: UFix64
    pub var mFUSDBorrowingAmountToken: UFix64
    pub var mBLTBorrowingAmountToken: UFix64

    //the limit of each token can be deposited
    pub var depositeLimitFLOWToken: UFix64
    pub var depositeLimitFUSD: UFix64
    pub var depositeLimitBLTToken: UFix64

    //the parameter of the protocol 
    pub var optimalUtilizationRate: UFix64
    pub var optimalBorrowApy: UFix64
    pub var loanToValueRatio: UFix64

    //the path of the protocol
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath

    //the rate of Flow been borrowed now
    pub fun getFlowUtilizationRate(): UFix64 {
        if(TokenLendingPlace.TokenVaultFlow.balance + TokenLendingPlace.mFlowBorrowingAmountToken * TokenLendingPlace.getmFlowBorrowingTokenPrice() != 0.0){
            return (TokenLendingPlace.mFlowBorrowingAmountToken * TokenLendingPlace.getmFlowBorrowingTokenPrice()) / (TokenLendingPlace.TokenVaultFlow.balance + TokenLendingPlace.mFlowBorrowingAmountToken * TokenLendingPlace.getmFlowBorrowingTokenPrice())
        }else {
            return 0.0
        }
    }

    //the rate of FUSD been borrowed now
    pub fun getFUSDUtilizationRate(): UFix64 {
        if(TokenLendingPlace.TokenVaultFUSD.balance + TokenLendingPlace.mFUSDBorrowingAmountToken * TokenLendingPlace.getmFUSDBorrowingTokenPrice() != 0.0){
            return (TokenLendingPlace.mFUSDBorrowingAmountToken * TokenLendingPlace.getmFUSDBorrowingTokenPrice()) / (TokenLendingPlace.TokenVaultFUSD.balance + TokenLendingPlace.mFUSDBorrowingAmountToken * TokenLendingPlace.getmFUSDBorrowingTokenPrice())
        }else{
            return 0.0
        }
    }
    
    //the rate of BLT been borrowed now
    pub fun getBLTUtilizationRate(): UFix64 {
        if(TokenLendingPlace.TokenVaultBLT.balance + TokenLendingPlace.mBLTBorrowingAmountToken * TokenLendingPlace.getmBLTBorrowingTokenPrice() != 0.0){
            return (TokenLendingPlace.mBLTBorrowingAmountToken * TokenLendingPlace.getmBLTBorrowingTokenPrice()) / (TokenLendingPlace.TokenVaultBLT.balance + TokenLendingPlace.mBLTBorrowingAmountToken * TokenLendingPlace.getmBLTBorrowingTokenPrice())
        }else{
            return 0.0
        }
    }

    //get mFlowBorrowingTokenPrice
    pub fun getmFlowBorrowingTokenPrice(): UFix64{
        let delta = getCurrentBlock().timestamp - TokenLendingPlace.finalTimestamp
        return TokenLendingPlace.mFlowBorrowingtokenPrice + delta * TokenLendingPlace.mFlowBorrowingInterestRate /( 365.0 * 24.0 * 60.0 * 60.0)
    }

    //get mFUSDBorrowingTokenPrice
    pub fun getmFUSDBorrowingTokenPrice(): UFix64{
        let delta = getCurrentBlock().timestamp - TokenLendingPlace.finalTimestamp
        return TokenLendingPlace.mFUSDBorrowingtokenPrice + delta * TokenLendingPlace.mFUSDBorrowingInterestRate/( 365.0 * 24.0 * 60.0 * 60.0)
    }

    //get mBLTBorrowingtokenPrice
    pub fun getmBLTBorrowingTokenPrice(): UFix64{
        let delta = getCurrentBlock().timestamp - TokenLendingPlace.finalTimestamp
        return TokenLendingPlace.mBLTBorrowingtokenPrice + delta * TokenLendingPlace.mBLTBorrowingInterestRate/( 365.0 * 24.0 * 60.0 * 60.0)
    }

    //get mFlowTokenPrice
     pub fun getmFlowTokenPrice(): UFix64{
        let delta = getCurrentBlock().timestamp - TokenLendingPlace.finalTimestamp
        return TokenLendingPlace.mFlowtokenPrice + delta * TokenLendingPlace.mFlowInterestRate
    }
    //get mFUSDTokenPrice
    pub fun getmFUSDTokenPrice(): UFix64{
        let delta = getCurrentBlock().timestamp - TokenLendingPlace.finalTimestamp
        return TokenLendingPlace.mFUSDtokenPrice + delta * TokenLendingPlace.mFUSDInterestRate
    }
    //get mBLTTokenPrice
    pub fun getmBLTTokenPrice(): UFix64{
        let delta = getCurrentBlock().timestamp - TokenLendingPlace.finalTimestamp
        return TokenLendingPlace.mBLTtokenPrice + delta * TokenLendingPlace.mBLTInterestRate
    }
    //get total supply
    pub fun getTotalsupply(): {String: UFix64} {
            return {"flowTotalSupply":TokenLendingPlace.TokenVaultFlow.balance + TokenLendingPlace.mFlowBorrowingAmountToken * TokenLendingPlace.getmFlowBorrowingTokenPrice(), "fusdTotalSupply": TokenLendingPlace.TokenVaultFUSD.balance + TokenLendingPlace.mFUSDBorrowingAmountToken * TokenLendingPlace.getmFUSDBorrowingTokenPrice(), "bltTotalSupply":TokenLendingPlace.TokenVaultBLT.balance + TokenLendingPlace.mBLTBorrowingAmountToken * TokenLendingPlace.getmBLTBorrowingTokenPrice()}
    }
    //get deposit limit
    pub fun getDepositLimit(): {String: UFix64} {
            return {"flowDepositLimit":TokenLendingPlace.depositeLimitFLOWToken,"fusdDepositLimit": TokenLendingPlace.depositeLimitFUSD, "bltDepositLimit":TokenLendingPlace.depositeLimitBLTToken}
    }
    //get total borrow
    pub fun getTotalBorrow(): {String: UFix64} {
            return {"flowTotalBorrow":TokenLendingPlace.mFlowBorrowingAmountToken * TokenLendingPlace.getmFlowBorrowingTokenPrice(),"fusdTotalBorrow": TokenLendingPlace.mFUSDBorrowingAmountToken * TokenLendingPlace.getmFUSDBorrowingTokenPrice(), "bltTotalBorrow":TokenLendingPlace.mBLTBorrowingAmountToken * TokenLendingPlace.getmBLTBorrowingTokenPrice()}
    }
    //get token real price
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
        pub fun getMyBorrowingmFlow(): UFix64
        pub fun getMyBorrowingmFUSD(): UFix64
        pub fun getMyBorrowingmBLT(): UFix64
        pub fun getMyTotalsupply(): UFix64
        pub fun getNetValue(): UFix64
        pub fun getMyTotalborrow(): UFix64
        pub fun liquidateFlow()
        pub fun liquidateFUSD()
        pub fun liquidateBLT()
    }

    //The method of updating mToken and interest rate in the protocol. Any part that changes the amount in the protocol (deposite, repay, withdrea, borrow, liquidty) will call this method. In this method we update the latest rate instantly.
    access(contract) fun updatePriceAndInterest(){
        //update token price
        let delta = getCurrentBlock().timestamp - TokenLendingPlace.finalTimestamp
        TokenLendingPlace.mFlowtokenPrice = TokenLendingPlace.mFlowtokenPrice + (delta * TokenLendingPlace.mFlowInterestRate / ( 365.0 * 24.0 * 60.0 * 60.0))
        TokenLendingPlace.mFUSDtokenPrice = TokenLendingPlace.mFUSDtokenPrice + (delta * TokenLendingPlace.mFUSDInterestRate / ( 365.0 * 24.0 * 60.0 * 60.0))
        TokenLendingPlace.mBLTtokenPrice = TokenLendingPlace.mBLTtokenPrice + (delta * TokenLendingPlace.mBLTInterestRate / ( 365.0 * 24.0 * 60.0 * 60.0))

        TokenLendingPlace.mFlowBorrowingtokenPrice = TokenLendingPlace.mFlowBorrowingtokenPrice + (delta * TokenLendingPlace.mFlowBorrowingInterestRate / ( 365.0 * 24.0 * 60.0 * 60.0))
        TokenLendingPlace.mFUSDBorrowingtokenPrice = TokenLendingPlace.mFUSDBorrowingtokenPrice + (delta * TokenLendingPlace.mFUSDBorrowingInterestRate / ( 365.0 * 24.0 * 60.0 * 60.0))
        TokenLendingPlace.mBLTBorrowingtokenPrice = TokenLendingPlace.mBLTBorrowingtokenPrice + (delta * TokenLendingPlace.mBLTBorrowingInterestRate / ( 365.0 * 24.0 * 60.0 * 60.0))
        TokenLendingPlace.finalTimestamp = getCurrentBlock().timestamp

        //update interestRate
        if(TokenLendingPlace.TokenVaultFlow.balance + TokenLendingPlace.mFlowBorrowingAmountToken * TokenLendingPlace.getmFlowBorrowingTokenPrice() != 0.0){
            if(TokenLendingPlace.getFlowUtilizationRate() < TokenLendingPlace.optimalUtilizationRate){
                TokenLendingPlace.mFlowBorrowingInterestRate = TokenLendingPlace.getFlowUtilizationRate() / TokenLendingPlace.optimalUtilizationRate * TokenLendingPlace.optimalBorrowApy
            }else{
               TokenLendingPlace.mFlowBorrowingInterestRate = (TokenLendingPlace.getFlowUtilizationRate() - TokenLendingPlace.optimalUtilizationRate) / (1.0 - TokenLendingPlace.optimalUtilizationRate) * ( 1.0 - TokenLendingPlace.optimalUtilizationRate) + TokenLendingPlace.optimalUtilizationRate
            }
            TokenLendingPlace.mFlowInterestRate = TokenLendingPlace.mFlowBorrowingInterestRate * TokenLendingPlace.getFlowUtilizationRate()
        }

        if(TokenLendingPlace.TokenVaultFUSD.balance + TokenLendingPlace.mFUSDBorrowingAmountToken * TokenLendingPlace.getmFUSDBorrowingTokenPrice() != 0.0){
            if(TokenLendingPlace.getFUSDUtilizationRate() < TokenLendingPlace.optimalUtilizationRate){
               TokenLendingPlace.mFUSDBorrowingInterestRate =TokenLendingPlace.getFUSDUtilizationRate() / TokenLendingPlace.optimalUtilizationRate*TokenLendingPlace.optimalBorrowApy
            }else{
                TokenLendingPlace.mFUSDBorrowingInterestRate = (TokenLendingPlace.getFUSDUtilizationRate() - TokenLendingPlace.optimalUtilizationRate) / (1.0 - TokenLendingPlace.optimalUtilizationRate) * (1.0 - TokenLendingPlace.optimalUtilizationRate) + TokenLendingPlace.optimalUtilizationRate
            }
            TokenLendingPlace.mFUSDInterestRate = TokenLendingPlace.mFUSDBorrowingInterestRate * TokenLendingPlace.getFUSDUtilizationRate()
        }

        if(TokenLendingPlace.TokenVaultBLT.balance + TokenLendingPlace.mBLTBorrowingAmountToken * TokenLendingPlace.getmBLTBorrowingTokenPrice() != 0.0){
            if(TokenLendingPlace.getBLTUtilizationRate() < TokenLendingPlace.optimalUtilizationRate){
                TokenLendingPlace.mBLTBorrowingInterestRate = TokenLendingPlace.getBLTUtilizationRate() / TokenLendingPlace.optimalUtilizationRate*TokenLendingPlace.optimalBorrowApy
            }else{
                TokenLendingPlace.mBLTBorrowingInterestRate = (TokenLendingPlace.getBLTUtilizationRate() - TokenLendingPlace.optimalUtilizationRate) / (1.0 - TokenLendingPlace.optimalUtilizationRate) * (1.0 - TokenLendingPlace.optimalUtilizationRate) + TokenLendingPlace.optimalUtilizationRate
            }
            TokenLendingPlace.mBLTInterestRate = TokenLendingPlace.mBLTBorrowingInterestRate * TokenLendingPlace.getBLTUtilizationRate()
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
    // The Token Collection resource records all the data of the user, and the user join in the protocol through this resource
    //
    pub resource TokenLendingCollection: TokenLendingPublic {

        //user mtoken amount, will be minted when deposit
        access(self) var mFlow: UFix64
        access(self) var mFUSD: UFix64
        access(self) var mBLT: UFix64

        //user mBorrowingtoken amount, will be minted when borrow
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

        pub fun getMyBorrowingmFlow(): UFix64 {
            return self.myBorrowingmFlow
        }

        pub fun getMyBorrowingmFUSD(): UFix64 {
            return self.myBorrowingmFUSD
        }

        pub fun getMyBorrowingmBLT(): UFix64 {
            return self.myBorrowingmBLT
        }

        //user deposit the token as Liquidity and mint mtoken
        pub fun addLiquidity(from: @FungibleToken.Vault) {

            var balance = 0.0
            if(from.getType() == Type<@FlowToken.Vault>()) {
                balance = from.balance
                TokenLendingPlace.TokenVaultFlow.deposit(from: <- from)
                self.mFlow = self.mFlow + (balance / TokenLendingPlace.getmFlowTokenPrice())
            } else if( from.getType() == Type<@FUSD.Vault>()) {
                balance = from.balance
                TokenLendingPlace.TokenVaultFUSD.deposit(from: <- from)
                self.mFUSD = self.mFUSD + (balance / TokenLendingPlace.getmFUSDTokenPrice())
            } else if( from.getType() == Type<@BloctoToken.Vault>()) {
                balance = from.balance
                TokenLendingPlace.TokenVaultBLT.deposit(from: <- from)
                self.mBLT = self.mBLT + (balance / TokenLendingPlace.getmBLTTokenPrice())
            }

            TokenLendingPlace.updatePriceAndInterest()
            self.checkDepositValid()

            //event
            emit Mint(minter: self.owner?.address , kind: FlowToken.getType(), mintAmount: balance, mintTokens: balance / TokenLendingPlace.getmBLTTokenPrice())
        }

        //user redeem mtoken and withdraw the token
        pub fun removeLiquidity(_amount: UFix64, _token: Int): @FungibleToken.Vault {

            if(_token == 0) {
                let mFlowAmount = _amount / TokenLendingPlace.getmFlowTokenPrice()
                self.mFlow = self.mFlow - mFlowAmount
                let tokenVault <- TokenLendingPlace.TokenVaultFlow.withdraw(amount: _amount) 
                TokenLendingPlace.updatePriceAndInterest()
                self.checkBorrowValid()
                //event
                emit Redeem(redeemer: self.owner?.address , kind: FlowToken.getType(), redeemAmount: _amount, redeemTokens: _amount / TokenLendingPlace.getmFlowTokenPrice())
                 return <- tokenVault
            } else if(_token == 1) {
                let mFUSDAmount = _amount / TokenLendingPlace.getmFUSDTokenPrice()
                self.mFUSD = self.mFUSD - mFUSDAmount
                let tokenVault <- TokenLendingPlace.TokenVaultFUSD.withdraw(amount: _amount) 
                TokenLendingPlace.updatePriceAndInterest()
                self.checkBorrowValid()
                //event
                emit Redeem(redeemer: self.owner?.address , kind: FUSD.getType(), redeemAmount: _amount, redeemTokens: _amount / TokenLendingPlace.getmFUSDTokenPrice())
                 return <- tokenVault
            } else {
                let mBLTAmount = _amount / TokenLendingPlace.getmBLTTokenPrice()
                self.mBLT = self.mBLT - mBLTAmount
                let tokenVault <- TokenLendingPlace.TokenVaultBLT.withdraw(amount: _amount) 
                TokenLendingPlace.updatePriceAndInterest()
                self.checkBorrowValid()
                //event
                emit Redeem(redeemer: self.owner?.address , kind: BloctoToken.getType(), redeemAmount: _amount, redeemTokens: _amount / TokenLendingPlace.getmBLTTokenPrice())
                 return <- tokenVault
            }
        }

        //get user's net value
        pub fun getNetValue(): UFix64 {
            
            //to usd
            let FlowPower = (self.mFlow * TokenLendingPlace.getmFlowTokenPrice() - self.myBorrowingmFlow * TokenLendingPlace.getmFlowBorrowingTokenPrice()) * TokenLendingPlace.FlowTokenRealPrice
            let FUSDPower = (self.mFUSD * TokenLendingPlace.getmFUSDTokenPrice() - self.myBorrowingmFUSD * TokenLendingPlace.getmFUSDBorrowingTokenPrice()) * TokenLendingPlace.FUSDRealPrice 
            let BLTPower = (self.mBLT * TokenLendingPlace.getmBLTTokenPrice() - self.myBorrowingmBLT * TokenLendingPlace.getmFUSDBorrowingTokenPrice()) * TokenLendingPlace.BLTTokenRealPrice 

            return FlowPower + FUSDPower + BLTPower
        }

        //get user's total supply
        pub fun getMyTotalsupply(): UFix64 {
            
            //to usd
            let FlowPower = self.mFlow * TokenLendingPlace.getmFlowTokenPrice() * TokenLendingPlace.FlowTokenRealPrice 
            let FUSDPower = self.mFUSD * TokenLendingPlace.getmFUSDTokenPrice() * TokenLendingPlace.FUSDRealPrice
            let BLTPower = self.mBLT * TokenLendingPlace.getmBLTTokenPrice() * TokenLendingPlace.BLTTokenRealPrice

            return FlowPower + FUSDPower + BLTPower
        }

        //get user's total borrow
        pub fun getMyTotalborrow(): UFix64 {

            //to usd
            let FlowBorrow = self.myBorrowingmFlow * TokenLendingPlace.getmFlowBorrowingTokenPrice() * TokenLendingPlace.FlowTokenRealPrice 
            let FUSDBorrow = self.myBorrowingmFUSD * TokenLendingPlace.getmFUSDBorrowingTokenPrice() * TokenLendingPlace.FUSDRealPrice
            let BLTBorrow = self.myBorrowingmBLT * TokenLendingPlace.getmBLTBorrowingTokenPrice() * TokenLendingPlace.BLTTokenRealPrice

            return FlowBorrow + FUSDBorrow + BLTBorrow
        }

        //user borrows flow token
        pub fun borrowFlow(_amount: UFix64): @FungibleToken.Vault {
            pre {
                TokenLendingPlace.TokenVaultFlow.balance - _amount >= 0.0: "Not enough Flow to borrow"
            }
            
            let AmountofmToken = _amount / TokenLendingPlace.getmFlowBorrowingTokenPrice()
            TokenLendingPlace.mFlowBorrowingAmountToken = AmountofmToken + TokenLendingPlace.mFlowBorrowingAmountToken

            self.myBorrowingmFlow = AmountofmToken + self.myBorrowingmFlow

            let tokenVault <- TokenLendingPlace.TokenVaultFlow.withdraw(amount: _amount)
            TokenLendingPlace.updatePriceAndInterest()
            self.checkBorrowValid()

            //event         
            emit Borrow(borrower: self.owner?.address, kind: FlowToken.getType(), borrowAmount: _amount)

            return <- tokenVault
        }

        //user borrows FUSD token
        pub fun borrowFUSD(_amount: UFix64): @FungibleToken.Vault {
            pre {
                TokenLendingPlace.TokenVaultFUSD.balance - _amount >= 0.0: "Not enough FUSD to borrow"
            }
            
            let AmountofmToken = _amount / TokenLendingPlace.getmFUSDBorrowingTokenPrice()
            TokenLendingPlace.mFUSDBorrowingAmountToken = AmountofmToken + TokenLendingPlace.mFUSDBorrowingAmountToken

            self.myBorrowingmFUSD = AmountofmToken + self.myBorrowingmFUSD

            let tokenVault <- TokenLendingPlace.TokenVaultFUSD.withdraw(amount: _amount)
            TokenLendingPlace.updatePriceAndInterest()
            self.checkBorrowValid()

            //event         
            emit Borrow(borrower: self.owner?.address, kind: FUSD.getType(), borrowAmount: _amount)

            return <- tokenVault
        }
        
        //user borrows BLT token
        pub fun borrowBLT(_amount: UFix64): @FungibleToken.Vault {
            pre {
                TokenLendingPlace.TokenVaultBLT.balance - _amount >= 0.0: "Not enough BLT to borrow"
            }            

            let AmountofmToken = _amount / TokenLendingPlace.getmBLTBorrowingTokenPrice()
            TokenLendingPlace.mBLTBorrowingAmountToken = AmountofmToken + TokenLendingPlace.mBLTBorrowingAmountToken

            self.myBorrowingmBLT = AmountofmToken + self.myBorrowingmBLT

            let tokenVault <- TokenLendingPlace.TokenVaultBLT.withdraw(amount: _amount)
            TokenLendingPlace.updatePriceAndInterest()
            self.checkBorrowValid()

            //event         
            emit Borrow(borrower: self.owner?.address, kind: BloctoToken.getType(), borrowAmount: _amount)

            return <- tokenVault
        }

        //user repay FLow
        pub fun repayFlow(from: @FlowToken.Vault){
            pre{
                self.myBorrowingmFlow - from.balance / TokenLendingPlace.getmFlowBorrowingTokenPrice() >= 0.0: "Repay too much flow"
            }

            TokenLendingPlace.mFlowBorrowingAmountToken = TokenLendingPlace.mFlowBorrowingAmountToken - from.balance / TokenLendingPlace.getmFlowBorrowingTokenPrice()
            self.myBorrowingmFlow = self.myBorrowingmFlow - from.balance / TokenLendingPlace.getmFlowBorrowingTokenPrice()
            
            //event
            emit RepayBorrow(payer: from.owner?.address, borrower: self.owner?.address, kind: FlowToken.getType(), repayAmount: from.balance)

            TokenLendingPlace.TokenVaultFlow.deposit(from: <- from )
            TokenLendingPlace.updatePriceAndInterest()
        }

        //user repay FUSD
        pub fun repayFUSD(from: @FUSD.Vault){
            pre{
                self.myBorrowingmFUSD - from.balance / TokenLendingPlace.getmFUSDBorrowingTokenPrice() >= 0.0: "Repay too much fusd"
            }

            TokenLendingPlace.mFUSDBorrowingAmountToken = TokenLendingPlace.mFUSDBorrowingAmountToken - from.balance / TokenLendingPlace.getmFUSDBorrowingTokenPrice()
            self.myBorrowingmFUSD = self.myBorrowingmFUSD - from.balance / TokenLendingPlace.getmFUSDBorrowingTokenPrice()
            
            //event
            emit RepayBorrow(payer: from.owner?.address, borrower: self.owner?.address, kind: FUSD.getType(), repayAmount: from.balance)

            TokenLendingPlace.TokenVaultFUSD.deposit(from: <- from )
            TokenLendingPlace.updatePriceAndInterest()
        }
            
        //user repay BLT
        pub fun repayBLT(from: @BloctoToken.Vault){
           pre{
                self.myBorrowingmBLT -  from.balance / TokenLendingPlace.getmBLTBorrowingTokenPrice() >= 0.0: "Repay too much blt"
            }

            TokenLendingPlace.mBLTBorrowingAmountToken = TokenLendingPlace.mBLTBorrowingAmountToken - from.balance / TokenLendingPlace.getmBLTBorrowingTokenPrice()
            self.myBorrowingmBLT = self.myBorrowingmBLT -  from.balance / TokenLendingPlace.getmBLTBorrowingTokenPrice()
            
            //event
            emit RepayBorrow(payer: from.owner?.address, borrower: self.owner?.address, kind: BloctoToken.getType(), repayAmount: from.balance)

            TokenLendingPlace.TokenVaultBLT.deposit(from: <- from )
            TokenLendingPlace.updatePriceAndInterest()
        }

        //Check does user borrowing exceeds the loan limit
        pub fun checkBorrowValid() {
            assert(self.getMyTotalborrow() / self.getMyTotalsupply() < TokenLendingPlace.loanToValueRatio , message: "greater then loanToValueRatio")
        }

        //Check does user borrowing exceeds the UtilizationRate
        pub fun checkLiquidValid() {
            assert(self.getMyTotalborrow() / self.getMyTotalsupply() > TokenLendingPlace.optimalUtilizationRate , message: "less then optimalUtilizationRate")
        }

        //Check if user deposit exceeds the deposit limit
        pub fun checkDepositValid() {
            assert((TokenLendingPlace.TokenVaultFlow.balance + TokenLendingPlace.mFlowBorrowingAmountToken * TokenLendingPlace.getmFlowBorrowingTokenPrice()) < TokenLendingPlace.depositeLimitFLOWToken , message: "greater then depositeLimitFLOWToken")
            assert((TokenLendingPlace.TokenVaultFUSD.balance + TokenLendingPlace.mFUSDBorrowingAmountToken * TokenLendingPlace.getmFUSDBorrowingTokenPrice()) < TokenLendingPlace.depositeLimitFUSD , message: "greater then depositeLimitFUSD")
            assert((TokenLendingPlace.TokenVaultBLT.balance + TokenLendingPlace.mBLTBorrowingAmountToken * TokenLendingPlace.getmBLTBorrowingTokenPrice()) < TokenLendingPlace.depositeLimitBLTToken , message: "greater then depositeLimitBLTToken")
        }

        //liquidate the user who exceeds the UtilizationRate
        pub fun liquidateFlow(from: @FungibleToken.Vault, liquidatorVault: &TokenLendingCollection){
            self.checkLiquidValid()
            //Flow in Flow out
            if(from.getType() == Type<@FlowToken.Vault>()) {

                assert(self.myBorrowingmFlow - (from.balance / TokenLendingPlace.getmFlowBorrowingTokenPrice()) >= 0.0, message: "liquidate too much flow")
                self.myBorrowingmFlow = self.myBorrowingmFlow - (from.balance / TokenLendingPlace.getmFlowBorrowingTokenPrice())

                let repaymoney = from.balance

                liquidatorVault.depositemFlow(from:(repaymoney * TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.getmFlowTokenPrice()))
                
                //event
                emit LiquidateBorrow(liquidator: from.owner?.address, borrower: self.owner?.address, kindRepay: FlowToken.getType(), kindSeize: FlowToken.getType(), repayAmount: from.balance, seizeTokens: (repaymoney * TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.getmFlowTokenPrice()))

                TokenLendingPlace.TokenVaultFlow.deposit(from: <- from)

                self.mFlow = self.mFlow - (repaymoney / TokenLendingPlace.getmFlowTokenPrice())

            } else if( from.getType() == Type<@FUSD.Vault>()) {
                //FUSD in Flow out
                assert(self.myBorrowingmFUSD - (from.balance / TokenLendingPlace.getmFUSDBorrowingTokenPrice()) >= 0.0, message: "liquidate too much flow")
                self.myBorrowingmFUSD = self.myBorrowingmFUSD - (from.balance / TokenLendingPlace.getmFUSDBorrowingTokenPrice())

                let repaymoney = from.balance

                liquidatorVault.depositemFlow(from:(repaymoney * TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.getmFlowTokenPrice()))
                
                //event
                emit LiquidateBorrow(liquidator: from.owner?.address, borrower: self.owner?.address, kindRepay: FUSD.getType(), kindSeize: FlowToken.getType(), repayAmount: from.balance, seizeTokens: (repaymoney * TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.getmFlowTokenPrice()))

                TokenLendingPlace.TokenVaultFUSD.deposit(from: <- from)

                self.mFlow = self.mFlow - (repaymoney * TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.getmFlowTokenPrice())
            } else if( from.getType() == Type<@BloctoToken.Vault>()) {
                 //BLT in Flow out
                assert(self.myBorrowingmBLT - (from.balance / TokenLendingPlace.getmBLTBorrowingTokenPrice()) >= 0.0, message: "liquidate too much flow")
                self.myBorrowingmBLT = self.myBorrowingmBLT - (from.balance / TokenLendingPlace.getmBLTBorrowingTokenPrice())

                let repaymoney = from.balance

                liquidatorVault.depositemFlow(from:(repaymoney * TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.getmFlowTokenPrice()))
                
                //event
                emit LiquidateBorrow(liquidator: from.owner?.address, borrower: self.owner?.address, kindRepay: BloctoToken.getType(), kindSeize: FlowToken.getType(), repayAmount: from.balance, seizeTokens: (repaymoney * TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.getmFlowTokenPrice()))

                TokenLendingPlace.TokenVaultBLT.deposit(from: <- from)

                self.mFlow = self.mFlow - (repaymoney * TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.getmFlowTokenPrice())
            }
            TokenLendingPlace.updatePriceAndInterest()
        }

        pub fun liquidateFUSD(from: @FungibleToken.Vault, liquidatorVault: &TokenLendingCollection){
            self.checkLiquidValid()
            //Flow in FUSD out
            if(from.getType() == Type<@FlowToken.Vault>()) {
                assert(self.myBorrowingmFlow - (from.balance / TokenLendingPlace.getmFlowBorrowingTokenPrice()) >= 0.0, message: "liquidate too much FUSD")
                self.myBorrowingmFlow = self.myBorrowingmFlow - (from.balance / TokenLendingPlace.getmFlowBorrowingTokenPrice())

                let repaymoney = from.balance

                liquidatorVault.depositemFUSD(from:(repaymoney * TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.getmFUSDTokenPrice()))
                
                //event
                emit LiquidateBorrow(liquidator: from.owner?.address, borrower: self.owner?.address, kindRepay: FlowToken.getType(), kindSeize: FUSD.getType(), repayAmount: from.balance, seizeTokens: (repaymoney * TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.getmFUSDTokenPrice()))

                TokenLendingPlace.TokenVaultFlow.deposit(from: <- from)

                self.mFUSD = self.mFUSD - (repaymoney * TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.getmFUSDTokenPrice())
            } else if( from.getType() == Type<@FUSD.Vault>()) {
                //FUSD in FUSD out
                assert(self.myBorrowingmFUSD - (from.balance / TokenLendingPlace.getmFUSDBorrowingTokenPrice()) >= 0.0, message: "liquidate too much FUSD")
                self.myBorrowingmFUSD = self.myBorrowingmFUSD - (from.balance / TokenLendingPlace.getmFUSDBorrowingTokenPrice())

                let repaymoney = from.balance

                liquidatorVault.depositemFUSD(from:(repaymoney * TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.getmFUSDTokenPrice()))
                
                //event
                emit LiquidateBorrow(liquidator: from.owner?.address, borrower: self.owner?.address, kindRepay: FUSD.getType(), kindSeize: FUSD.getType(), repayAmount: from.balance, seizeTokens:(repaymoney * TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.getmFUSDTokenPrice()))

                TokenLendingPlace.TokenVaultFUSD.deposit(from: <- from)

                self.mFUSD = self.mFUSD - (repaymoney * TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.getmFUSDTokenPrice())
            } else if( from.getType() == Type<@BloctoToken.Vault>()) {
                 //BLT in FUSD out
                assert(self.myBorrowingmBLT - (from.balance / TokenLendingPlace.getmBLTBorrowingTokenPrice()) >= 0.0, message: "liquidate too much FUSD")
                self.myBorrowingmBLT = self.myBorrowingmBLT - (from.balance / TokenLendingPlace.getmBLTBorrowingTokenPrice())

                let repaymoney = from.balance

                liquidatorVault.depositemFUSD(from:(repaymoney * TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.getmFUSDTokenPrice()))
                
                //event
                emit LiquidateBorrow(liquidator: from.owner?.address, borrower: self.owner?.address, kindRepay: BloctoToken.getType(), kindSeize: FUSD.getType(), repayAmount: from.balance, seizeTokens:(repaymoney * TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.getmFUSDTokenPrice()))

                TokenLendingPlace.TokenVaultBLT.deposit(from: <- from)

                self.mFUSD = self.mFUSD - (repaymoney * TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.getmFUSDTokenPrice())
            }
            TokenLendingPlace.updatePriceAndInterest()
        }

        pub fun liquidateBLT(from: @FungibleToken.Vault, liquidatorVault: &TokenLendingCollection){
            self.checkLiquidValid()
            //Flow in BLT out
            if(from.getType() == Type<@FlowToken.Vault>()) {
                assert(self.myBorrowingmFlow - (from.balance / TokenLendingPlace.getmFlowBorrowingTokenPrice()) >= 0.0, message: "liquidate too much BLT")
                self.myBorrowingmFlow = self.myBorrowingmFlow - (from.balance / TokenLendingPlace.getmFlowBorrowingTokenPrice())

                let repaymoney = from.balance

                liquidatorVault.depositemBLT(from:(repaymoney * TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.getmBLTTokenPrice()))
                
                //event
                emit LiquidateBorrow(liquidator: from.owner?.address, borrower: self.owner?.address, kindRepay: FlowToken.getType(), kindSeize: BloctoToken.getType(), repayAmount: from.balance, seizeTokens:(repaymoney * TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.getmBLTTokenPrice()))

                TokenLendingPlace.TokenVaultFlow.deposit(from: <- from)

                self.mBLT = self.mBLT - (repaymoney * TokenLendingPlace.FlowTokenRealPrice / TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.getmBLTTokenPrice())
            } else if( from.getType() == Type<@FUSD.Vault>()) {
                //FUSD in BLT out
                assert(self.myBorrowingmFUSD - (from.balance / TokenLendingPlace.getmFUSDBorrowingTokenPrice()) >= 0.0, message: "liquidate too much BLT")
                self.myBorrowingmFUSD = self.myBorrowingmFUSD - (from.balance / TokenLendingPlace.getmFUSDBorrowingTokenPrice())

                let repaymoney = from.balance

                liquidatorVault.depositemBLT(from:(repaymoney * TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.getmBLTTokenPrice()))
                
                //event
                emit LiquidateBorrow(liquidator: from.owner?.address, borrower: self.owner?.address, kindRepay: FUSD.getType(), kindSeize: BloctoToken.getType(), repayAmount: from.balance, seizeTokens:(repaymoney * TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.getmBLTTokenPrice()))

                TokenLendingPlace.TokenVaultFUSD.deposit(from: <- from)

                self.mBLT = self.mBLT - (repaymoney * TokenLendingPlace.FUSDRealPrice / TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.getmBLTTokenPrice())
            } else if( from.getType() == Type<@BloctoToken.Vault>()) {
                 //BLT in BLT out
                assert(self.myBorrowingmBLT - (from.balance / TokenLendingPlace.getmBLTBorrowingTokenPrice()) >= 0.0, message: "liquidate too much BLT")
                self.myBorrowingmBLT = self.myBorrowingmBLT - (from.balance / TokenLendingPlace.getmBLTBorrowingTokenPrice())

                let repaymoney = from.balance

                liquidatorVault.depositemBLT(from:(repaymoney * TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.getmBLTTokenPrice()))
                
                //event
                emit LiquidateBorrow(liquidator: from.owner?.address, borrower: self.owner?.address, kindRepay: BloctoToken.getType(), kindSeize: BloctoToken.getType(), repayAmount: from.balance, seizeTokens:(repaymoney * TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.getmBLTTokenPrice()))

                TokenLendingPlace.TokenVaultBLT.deposit(from: <- from)

                self.mBLT = self.mBLT - (repaymoney * TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.BLTTokenRealPrice / TokenLendingPlace.getmBLTTokenPrice())
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
        self.TokenVaultFlow <- FlowToken.createEmptyVault() as! @FlowToken.Vault
        self.TokenVaultFUSD <- FUSD.createEmptyVault() as! @FUSD.Vault
        self.TokenVaultBLT <- BloctoToken.createEmptyVault() as! @BloctoToken.Vault

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