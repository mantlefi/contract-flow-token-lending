import FungibleToken from 0x01
import FlowToken from 0x02
import USDCToken from 0x03
import BloctoToken from 0x05

// Marketplace.cdc
//
// The Marketplace contract is a sample implementation of an NFT Marketplace on Flow.
//
// This contract allows users to put their NFTs up for sale. Other users
// can purchase these NFTs with fungible tokens.
//
// Learn more about marketplaces in this tutorial: https://docs.onflow.org/docs/composable-smart-contracts-marketplace

pub contract TokenLendPlace {

    // Event that is emitted when a new NFT is put up for sale
    pub event Borrowed(address: Address?)


    access(contract) let tokenVaultFlow: @FlowToken.Vault
    access(contract) let tokenVaultUSDC: @USDCToken.Vault
    access(contract) let tokenVaultBLT: @BloctoToken.Vault

    pub var mFlowtokenPrice: UFix64    //price only increase
    pub var mUSDCtokenPrice: UFix64
    pub var mBLTtokenPrice: UFix64

    pub var FlowTokenRealPrice: UFix64
    pub var USDCTokenRealPrice: UFix64
    pub var BLTTokenRealPrice: UFix64

    pub var mFlowInterestRate: UFix64    //delta of mFlowtokenPrice
    pub var mUSDCInterestRate: UFix64 
    pub var mBLTInterestRate: UFix64 

    pub var finalBlock: UInt64

    pub var FlowBorrowAmountToken: UFix64
    pub var USDCBorrowAmountToken: UFix64
    pub var BLTBorrowAmountToken: UFix64

    pub var depositeLimitFLOWToken: UFix64
    pub var depositeLimitUSDCToken: UFix64
    pub var depositeLimitBLTToken: UFix64


    // Interface that users will publish for their Sale collection
    // that only exposes the methods that are supposed to be public
    //
    pub resource interface TokenLandPublic {
        pub fun getmFlow(): UFix64
        pub fun getmUSDC(): UFix64
        pub fun getmBLT(): UFix64
        pub fun getmyBorrowingmFlow(): UFix64
        pub fun getmyBorrowingmUSDC(): UFix64
        pub fun getmyBorrowingmBLT(): UFix64
        pub fun getMaxBorrowingPower(): UFix64?
        pub fun getBorrowingNow(): UFix64?
        //pub fun liquidate(token: FungibleToken): FungibleToken
        //pub fun getBorrowingPower(): UInt64
        //pub fun getMaxBorrowingPower(): UInt64
    }

    access(contract) fun updatePriceAndInterest(){
      //update token price
      //let delta = getCurrentBlock().height - TokenLendPlace.finalBlock
      let delta = 0
      TokenLendPlace.mFlowtokenPrice = TokenLendPlace.mFlowtokenPrice + (delta as! UFix64 * TokenLendPlace.mFlowInterestRate)
      TokenLendPlace.mUSDCtokenPrice = TokenLendPlace.mUSDCtokenPrice + (delta as! UFix64 * TokenLendPlace.mUSDCInterestRate)
      TokenLendPlace.mBLTtokenPrice = TokenLendPlace.mBLTtokenPrice + (delta as! UFix64 * TokenLendPlace.mBLTInterestRate)

      //TokenLendPlace.finalBlock = getCurrentBlock().height
      TokenLendPlace.finalBlock = 0

      //update interestRate
      //TokenLendPlace.mFlowInterestRate = TokenLendPlace.FlowBorrowAmountToken / TokenLendPlace.tokenVaultFlow.balance
      //TokenLendPlace.mUSDCInterestRate = TokenLendPlace.USDCBorrowAmountToken / TokenLendPlace.tokenVaultUSDC.balance
    }

    //TODO, waiting real feed source, and limit certain caller.
    pub fun updatePricefromOracle(_FlowPrice: UFix64, _USDCPrice: UFix64){
      self.FlowTokenRealPrice = _FlowPrice
      self.USDCTokenRealPrice = _USDCPrice
    }

    // SaleCollection
    //
    // NFT Collection object that allows a user to put their NFT up for sale
    // where others can send fungible tokens to purchase it
    //
    pub resource TokenLandCollection: TokenLandPublic {

        access(self) var mFlow: UFix64
        access(self) var mUSDC: UFix64
        access(self) var mBLT: UFix64

        access(self) var myBorrowingmFlow: UFix64
        access(self) var myBorrowingmUSDC: UFix64
        access(self) var myBorrowingmBLT: UFix64

        init () {
            self.mFlow = 0.0
            self.mUSDC = 0.0
            self.mBLT = 0.0

            self.myBorrowingmFlow = 0.0
            self.myBorrowingmUSDC = 0.0
            self.myBorrowingmBLT = 0.0
        }

        pub fun getmFlow(): UFix64 {
            return self.mFlow
        }
        pub fun getmUSDC(): UFix64 {
            return self.mUSDC
        }
        pub fun getmBLT(): UFix64 {
            return self.mBLT
        }
        pub fun getmyBorrowingmFlow(): UFix64 {
            return self.myBorrowingmFlow
        }
        pub fun getmyBorrowingmUSDC(): UFix64 {
            return self.myBorrowingmUSDC
        }
        pub fun getmyBorrowingmBLT(): UFix64 {
            return self.myBorrowingmBLT
        }
   
        pub fun addLiquidity(from: @FungibleToken.Vault) {
            pre {
                //only allow the type of from is Flow and USDC Vault token
            }

            //TokenLendPlace.updatePriceAndInterest()

            if(from.getType() == Type<@FlowToken.Vault>()) {
                let balance = from.balance
                TokenLendPlace.tokenVaultFlow.deposit(from: <- from)
                self.mFlow = self.mFlow + (balance / TokenLendPlace.mFlowtokenPrice)
            } else if( from.getType() == Type<@USDCToken.Vault>()) {
                let balance = from.balance
                TokenLendPlace.tokenVaultUSDC.deposit(from: <- from)
                self.mUSDC = self.mUSDC + (balance / TokenLendPlace.mUSDCtokenPrice)
            } else if( from.getType() == Type<@BloctoToken.Vault>()) {
                let balance = from.balance
                TokenLendPlace.tokenVaultBLT.deposit(from: <- from)
                self.mBLT = self.mBLT + (balance / TokenLendPlace.mBLTtokenPrice)
            }

            //event
        }

        pub fun removeLiquidity(_amount: UFix64, _token: Int): @FungibleToken.Vault {
            //TokenLendPlace.updatePriceAndInterest()

            if(_token == 0) {
                self.mFlow = self.mFlow - _amount
                let tokenVault <- TokenLendPlace.tokenVaultFlow.withdraw(amount: (_amount * TokenLendPlace.mFlowtokenPrice)) 

                //event
                 return <- tokenVault
            } else if(_token == 1) {
                self.mUSDC = self.mUSDC - _amount
                let tokenVault <- TokenLendPlace.tokenVaultUSDC.withdraw(amount: (_amount * TokenLendPlace.mUSDCtokenPrice)) 

                //event
                 return <- tokenVault
            } else {
                self.mBLT = self.mBLT - _amount
                let tokenVault <- TokenLendPlace.tokenVaultBLT.withdraw(amount: (_amount * TokenLendPlace.mBLTtokenPrice)) 

                //event
                 return <- tokenVault
            }

        }

        pub fun getBorrowingPower(): UFix64? {
            
            //美元計價
            let FlowPower = (self.mFlow - self.myBorrowingmFlow) * TokenLendPlace.mFlowtokenPrice * TokenLendPlace.FlowTokenRealPrice
            let USDCPower = (self.mUSDC - self.myBorrowingmUSDC) * TokenLendPlace.mUSDCtokenPrice * TokenLendPlace.USDCTokenRealPrice 
            let BLTPower = (self.mBLT - self.myBorrowingmBLT) * TokenLendPlace.mBLTtokenPrice * TokenLendPlace.BLTTokenRealPrice 

            return FlowPower + USDCPower + BLTPower
        }

        pub fun getMaxBorrowingPower(): UFix64? {
            
            //美元計價
            let FlowPower = self.mFlow * TokenLendPlace.mFlowtokenPrice * TokenLendPlace.FlowTokenRealPrice 
            let USDCPower = self.mUSDC * TokenLendPlace.mUSDCtokenPrice * TokenLendPlace.USDCTokenRealPrice
            let BLTPower = self.mBLT * TokenLendPlace.mBLTtokenPrice * TokenLendPlace.BLTTokenRealPrice

            return FlowPower + USDCPower + BLTPower
        }
        pub fun getBorrowingNow(): UFix64? {
            
            //美元計價
            let FlowBorrow = self.myBorrowingmFlow * TokenLendPlace.mFlowtokenPrice * TokenLendPlace.FlowTokenRealPrice 
            let USDCBorrow = self.myBorrowingmUSDC * TokenLendPlace.mUSDCtokenPrice * TokenLendPlace.USDCTokenRealPrice
            let BLTBorrow = self.myBorrowingmBLT * TokenLendPlace.mBLTtokenPrice * TokenLendPlace.BLTTokenRealPrice

            return FlowBorrow + USDCBorrow + BLTBorrow
        }

        pub fun borrowFlow(_amount: UFix64): @FungibleToken.Vault {
            pre {
                TokenLendPlace.tokenVaultFlow.balance - TokenLendPlace.FlowBorrowAmountToken > _amount: "Amount minted must be greater than zero"
                (self.getBorrowingPower() ?? 0.0 * 0.6) > (TokenLendPlace.FlowTokenRealPrice * _amount) : "Amount minted must be greater than zero"
            }

            emit Borrowed(address: self.owner?.address)
            
            //TokenLendPlace.updatePriceAndInterest()

            let realAmountofToken = _amount * TokenLendPlace.mFlowtokenPrice
            TokenLendPlace.FlowBorrowAmountToken = realAmountofToken + TokenLendPlace.FlowBorrowAmountToken

            self.myBorrowingmFlow = _amount + self.myBorrowingmFlow

            let token1Vault <- TokenLendPlace.tokenVaultFlow.withdraw(amount: realAmountofToken)
            return <- token1Vault
        }

        //Repay
        pub fun repayFlow(from: @FlowToken.Vault){
            //unlock the borrowing power

            //TokenLendPlace.updatePriceAndInterest()

            TokenLendPlace.FlowBorrowAmountToken = TokenLendPlace.FlowBorrowAmountToken - from.balance
            self.myBorrowingmFlow = self.myBorrowingmFlow - (from.balance / TokenLendPlace.mFlowtokenPrice)

            TokenLendPlace.tokenVaultFlow.deposit(from: <- from )
        }

        pub fun liquidateFlow(from: @FungibleToken.Vault, liquidatorVault: &TokenLandCollection){
            
            //TokenLendPlace.updatePriceAndInterest()

            //flow in flow out
            if(from.getType() == Type<@FlowToken.Vault>()) {
                self.myBorrowingmFlow = self.myBorrowingmFlow - (from.balance / TokenLendPlace.mFlowtokenPrice)

                let repaymoney = from.balance * 1.05

                liquidatorVault.depositemFlow(from:(repaymoney / TokenLendPlace.mFlowtokenPrice))

                TokenLendPlace.tokenVaultFlow.deposit(from: <- from)

                self.mFlow = self.mFlow - (repaymoney / TokenLendPlace.mFlowtokenPrice)

                //let token1Vault <- TokenLendPlace.tokenVaultFlow.withdraw(amount: repaymoney)
                //return <- token1Vault
            } else

            //usdc in flow out
            //if( from.getType() == Type<@USDCToken.Vault>()) 
            {
                TokenLendPlace.USDCBorrowAmountToken = TokenLendPlace.USDCBorrowAmountToken - from.balance
                self.myBorrowingmUSDC = self.myBorrowingmUSDC - (from.balance / TokenLendPlace.mUSDCtokenPrice)
                
                let repaymoney = from.balance * 1.05 / TokenLendPlace.FlowTokenRealPrice

                liquidatorVault.depositemUSDC(from:(repaymoney / TokenLendPlace.mUSDCtokenPrice))

                TokenLendPlace.tokenVaultUSDC.deposit(from: <- from)

                self.mFlow = self.mFlow - (repaymoney / TokenLendPlace.mFlowtokenPrice)

                //let tokenVault <- TokenLendPlace.tokenVaultFlow.withdraw(amount: repaymoney)
                //return <- tokenVault
            }

            //return <- TokenLendPlace.tokenVaultFlow.withdraw(amount: 0.0)
        }
        access(self) fun depositemFlow(from: UFix64) {
            self.mFlow = self.mFlow + from
        }
        access(self) fun depositemUSDC(from: UFix64) {
            self.mUSDC = self.mUSDC + from
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
        self.tokenVaultUSDC <- USDCToken.createEmptyVault() as! @USDCToken.Vault
        self.tokenVaultBLT <- BloctoToken.createEmptyVault() as! @BloctoToken.Vault

        self.mFlowInterestRate = 0.00005
        self.mUSDCInterestRate = 0.00005
        self.mBLTInterestRate = 0.00005
        self.mFlowtokenPrice = 1.0
        self.mUSDCtokenPrice = 1.0
        self.mBLTtokenPrice = 1.0
        self.FlowTokenRealPrice = 10.0
        self.USDCTokenRealPrice = 1.0
        self.BLTTokenRealPrice = 1.0
        self.finalBlock = 0 //getCurrentBlock().height

        self.FlowBorrowAmountToken = 0.0
        self.USDCBorrowAmountToken = 0.0
        self.BLTBorrowAmountToken = 0.0

        self.depositeLimitFLOWToken = 100000.0
        self.depositeLimitUSDCToken = 1000000.0
        self.depositeLimitBLTToken = 1000000.0


  }
}
 
