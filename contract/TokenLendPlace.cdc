import FungibleToken from 0x01
import FlowToken from 0x02
import USDCToken from 0x03

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
    pub event ForSale(id: UInt64, price: UFix64)

    // Event that is emitted when the price of an NFT changes
    pub event PriceChanged(id: UInt64, newPrice: UFix64)
    
    // Event that is emitted when a token is purchased
    pub event TokenPurchased(id: UInt64, price: UFix64)

    // Event that is emitted when a seller withdraws their NFT from the sale
    pub event SaleWithdrawn(id: UInt64)

    access(contract) let tokenVaultFlow: @FlowToken.Vault
    access(contract) let tokenVaultUSDC: @USDCToken.Vault

    pub var mFlowtokenPrice: UFix64    //price only increase
    pub var mUSDCtokenPrice: UFix64

    pub var FlowTokenRealPrice: UFix64
    pub var USDCTokenRealPrice: UFix64

    pub var mFlowInterestRate: UFix64    //delta of mFlowtokenPrice
    pub var mUSDCInterestRate: UFix64 

    pub var finalBlock: UInt64

    pub var FlowBorrowAmountToken: UFix64
    pub var USDCBorrowAmountToken: UFix64

    pub var depositeLimitFLOWToken: UFix64
    pub var depositeLimitUSDCToken: UFix64

    // Interface that users will publish for their Sale collection
    // that only exposes the methods that are supposed to be public
    //
    pub resource interface TokenLandPublic {
        //pub fun liquidate(token: FungibleToken): FungibleToken
        //pub fun getBorrowingPower(): UInt64
        //pub fun getMaxBorrowingPower(): UInt64
    }

    access(contract) fun updatePriceAndInterest(){
      //update token price
      let delta = getCurrentBlock().height - TokenLendPlace.finalBlock
      TokenLendPlace.mFlowtokenPrice = TokenLendPlace.mFlowtokenPrice + (delta as! UFix64 * TokenLendPlace.mFlowInterestRate)
      TokenLendPlace.mUSDCtokenPrice = TokenLendPlace.mUSDCtokenPrice + (delta as! UFix64 * TokenLendPlace.mUSDCInterestRate)
      TokenLendPlace.finalBlock = getCurrentBlock().height

      //update interestRate
      TokenLendPlace.mFlowInterestRate = TokenLendPlace.FlowBorrowAmountToken / TokenLendPlace.tokenVaultFlow.balance
      TokenLendPlace.mUSDCInterestRate = TokenLendPlace.USDCBorrowAmountToken / TokenLendPlace.tokenVaultUSDC.balance
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

        pub var mFlow: UFix64
        pub var mUSDC: UFix64

        pub var myBorrowingmFlow: UFix64
        pub var myBorrowingmUSDC: UFix64

        init () {
            self.mFlow = 0.0
            self.mUSDC = 0.0

            self.myBorrowingmFlow = 0.0
            self.myBorrowingmUSDC = 0.0
        }
   
        pub fun addLiquidity(from: @FungibleToken.Vault) {
            pre {
                //only allow the type of from is Flow and USDC Vault token
            }

            TokenLendPlace.updatePriceAndInterest()

            if(from.getType() == Type<@FlowToken.Vault>()) {
                let balance = from.balance
                TokenLendPlace.tokenVaultFlow.deposit(from: <- from)
                self.mFlow = self.mFlow + (balance / TokenLendPlace.mFlowtokenPrice)
            } else if( from.getType() == Type<@USDCToken.Vault>()) {
                let balance = from.balance
                TokenLendPlace.tokenVaultUSDC.deposit(from: <- from)
                self.mUSDC = self.mUSDC + (balance / TokenLendPlace.mUSDCtokenPrice)
            }

            //event
        }

        pub fun removeLiquidity(_amount: UFix64, _token: Int): @FungibleToken.Vault {
            TokenLendPlace.updatePriceAndInterest()

            if(_token == 0) {
                self.mFlow = self.mFlow - _amount
                let token1Vault <- TokenLendPlace.tokenVaultFlow.withdraw(amount: (_amount * TokenLendPlace.mFlowtokenPrice)) 

                //event
                 return <- token1Vault
            } else if(_token == 1) {
                self.mUSDC = self.mUSDC - _amount
                let token1Vault <- TokenLendPlace.tokenVaultUSDC.withdraw(amount: (_amount * TokenLendPlace.mUSDCtokenPrice)) 

                //event
                 return <- token1Vault
            }

            return <- TokenLendPlace.tokenVaultUSDC.withdraw(amount: 0.0)
        }

        pub fun getBorrowingPower(): UFix64? {
            
            //美元計價
            let FlowPower = (self.mFlow - self.myBorrowingmFlow) * TokenLendPlace.mFlowtokenPrice * TokenLendPlace.FlowTokenRealPrice
            let USDCPower = (self.mUSDC - self.myBorrowingmUSDC) * TokenLendPlace.mUSDCtokenPrice * TokenLendPlace.USDCTokenRealPrice 

            return FlowPower + USDCPower
        }

        pub fun getMaxBorrowingPower(): UFix64? {
            
            //美元計價
            let FlowPower = self.mFlow * TokenLendPlace.mFlowtokenPrice * TokenLendPlace.FlowTokenRealPrice 
            let USDCPower = self.mUSDC * TokenLendPlace.mUSDCtokenPrice * TokenLendPlace.USDCTokenRealPrice

            return FlowPower + USDCPower
        }

        pub fun borrowFlow(_amount: UFix64): @FungibleToken.Vault {
            pre {
                TokenLendPlace.tokenVaultFlow.balance - TokenLendPlace.FlowBorrowAmountToken > _amount: "Amount minted must be greater than zero"
                (self.getBorrowingPower() ?? 0.0 * 0.6) > (TokenLendPlace.FlowTokenRealPrice * _amount) : "Amount minted must be greater than zero"
            }
            
            TokenLendPlace.updatePriceAndInterest()

            let realAmountofToken = _amount * TokenLendPlace.mFlowtokenPrice
            TokenLendPlace.FlowBorrowAmountToken = realAmountofToken + TokenLendPlace.FlowBorrowAmountToken

            self.myBorrowingmFlow = _amount + self.myBorrowingmFlow

            let token1Vault <- TokenLendPlace.tokenVaultFlow.withdraw(amount: realAmountofToken)
            return <- token1Vault
        }

        //Repay
        pub fun repayFlow(from: @FlowToken.Vault){
            //unlock the borrowing power

            TokenLendPlace.updatePriceAndInterest()

            TokenLendPlace.FlowBorrowAmountToken = TokenLendPlace.FlowBorrowAmountToken - from.balance
            self.myBorrowingmFlow = self.myBorrowingmFlow - (from.balance / TokenLendPlace.mFlowtokenPrice)

            TokenLendPlace.tokenVaultFlow.deposit(from: <- from )
        }

        pub fun liquidateFlow(from: @FungibleToken.Vault): @FungibleToken.Vault{
            
            TokenLendPlace.updatePriceAndInterest()

            //flow in flow out
            if(from.getType() == Type<@FlowToken.Vault>()) {
                TokenLendPlace.FlowBorrowAmountToken = TokenLendPlace.FlowBorrowAmountToken - from.balance
                self.myBorrowingmFlow = self.myBorrowingmFlow - (from.balance / TokenLendPlace.mFlowtokenPrice)

                let repaymoney = from.balance * 1.05

                TokenLendPlace.tokenVaultFlow.deposit(from: <- from)

                self.mFlow = self.mFlow - (repaymoney / TokenLendPlace.mFlowtokenPrice)

                let token1Vault <- TokenLendPlace.tokenVaultFlow.withdraw(amount: repaymoney)
                return <- token1Vault
            }

            //usdc in flow out
            if( from.getType() == Type<@USDCToken.Vault>()) {
                TokenLendPlace.USDCBorrowAmountToken = TokenLendPlace.USDCBorrowAmountToken - from.balance
                self.myBorrowingmUSDC = self.myBorrowingmUSDC - (from.balance / TokenLendPlace.mUSDCtokenPrice)
                
                let repaymoney = from.balance * 1.05 / TokenLendPlace.FlowTokenRealPrice

                TokenLendPlace.tokenVaultUSDC.deposit(from: <- from)

                self.mFlow = self.mFlow - (repaymoney / TokenLendPlace.mFlowtokenPrice)

                let tokenVault <- TokenLendPlace.tokenVaultFlow.withdraw(amount: repaymoney)
                return <- tokenVault
            }

            return <- TokenLendPlace.tokenVaultFlow.withdraw(amount: 0.0)
        }
    }

    // createCollection returns a new collection resource to the caller
    pub fun createTokenLandCollection(): @TokenLandCollection {
        return <- create TokenLandCollection()
    }

    init() {
        self.tokenVaultFlow <- FlowToken.createEmptyVault() as! @FlowToken.Vault
        self.tokenVaultUSDC <- USDCToken.createEmptyVault() as! @USDCToken.Vault

        self.mFlowInterestRate = 0.00005
        self.mUSDCInterestRate = 0.00005
        self.mFlowtokenPrice = 1.0
        self.mUSDCtokenPrice = 1.0
        self.FlowTokenRealPrice = 10.0
        self.USDCTokenRealPrice = 1.0
        self.finalBlock = 100 //getCurrentBlock().height

        self.FlowBorrowAmountToken = 0.0
        self.USDCBorrowAmountToken = 0.0

        self.depositeLimitFLOWToken = 100000.0
        self.depositeLimitUSDCToken = 1000000.0
  }
}
 
