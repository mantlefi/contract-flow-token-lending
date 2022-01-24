


    TokenLendingPlace = {
        mFlowtokenPrice: 0,   //price only increase
        mFUSDtokenPrice: 0,
    
        FlowTokenRealPrice: 0,
        FUSDTokenRealPrice: 0,
    
        mFlowInterestRate: 0,    //delta of mFlowtokenPrice
        mFUSDInterestRate: 0, 
    
        finalBlock: 0,
    
        mFlowBorrowAmountToken: 0,
        mFUSDBorrowAmountToken: 0,
    
        mFlowBorrowingtokenPrice: 0,   
        mFUSDBorrowingtokenPrice: 0,
    
        mFlowBorrowingInterestRate: 0,    
        mFUSDBorrowingInterestRate: 0, 

        depositeLimitFLOWToken: 0,
        depositeLimitFUSDToken: 0,

        tokenVaultFlow: {
            balance: 0
        },

        tokenVaultFUSD: {
            balance: 0
        },
        tempBlock: 0
    }


    function getCurrentBlock(){
        return {
            height: TokenLendingPlace.tempBlock
        }
    }

    function updatePriceAndInterest(){
        //update interestRate
        TokenLendingPlace.mFlowInterestRate = TokenLendingPlace.mFlowBorrowAmountToken == 0 ? 0 : getFlowLoanInterest() / 365 / 24 / 60 / 30
        TokenLendingPlace.mFUSDInterestRate = TokenLendingPlace.mFUSDBorrowAmountToken == 0 ? 0 : getFUSDLoanInterest / 365 / 24 / 60 / 30

        TokenLendingPlace.mFlowBorrowingInterestRate = TokenLendingPlace.mFlowBorrowAmountToken == 0 ? 0 : getFlowBorrowingInterest() / 365 / 24 / 60 / 30
        TokenLendingPlace.mFUSDBorrowingInterestRate = TokenLendingPlace.mFUSDBorrowAmountToken == 0 ? 0 : getFUSDBorrowingInterest() / 365 / 24 / 60 / 30

        //update token price
        let delta = getCurrentBlock().height - TokenLendingPlace.finalBlock

        TokenLendingPlace.mFlowtokenPrice = TokenLendingPlace.mFlowtokenPrice + (delta * TokenLendingPlace.mFlowInterestRate)
        TokenLendingPlace.mFUSDtokenPrice = TokenLendingPlace.mFUSDtokenPrice + (delta * TokenLendingPlace.mFUSDInterestRate)
        TokenLendingPlace.mFlowBorrowingtokenPrice = TokenLendingPlace.mFlowBorrowingtokenPrice + (delta * TokenLendingPlace.mFlowBorrowingInterestRate)
        TokenLendingPlace.mFUSDBorrowingtokenPrice = TokenLendingPlace.mFUSDBorrowingtokenPrice + (delta * TokenLendingPlace.mFUSDBorrowingInterestRate)
        TokenLendingPlace.finalBlock = getCurrentBlock().height
    }

    //TODO, waiting real feed source, and limit certain caller.
    function updatePricefromOracle(_FlowPrice, _FUSDPrice){
      self.FlowTokenRealPrice = _FlowPrice
      self.FUSDTokenRealPrice = _FUSDPrice
    }


    function init() {

        TokenLendingPlace.mFlowInterestRate = 0
        TokenLendingPlace.mFUSDInterestRate = 0
        TokenLendingPlace.mFlowtokenPrice = 1.0
        TokenLendingPlace.mFUSDtokenPrice = 1.0
        TokenLendingPlace.FlowTokenRealPrice = 10.0
        TokenLendingPlace.FUSDTokenRealPrice = 1.0
        TokenLendingPlace.finalBlock = 0 //getCurrentBlock().height

        TokenLendingPlace.mFlowBorrowAmountToken = 0.0
        TokenLendingPlace.mFUSDBorrowAmountToken = 0.0

        TokenLendingPlace.mFlowBorrowingtokenPrice = 1.0
        TokenLendingPlace.mFUSDBorrowingtokenPrice = 1.0
    
        TokenLendingPlace.mFlowBorrowingInterestRate = 0
        TokenLendingPlace.mFUSDBorrowingInterestRate = 0

        TokenLendingPlace.depositeLimitFLOWToken = 100000.0
        TokenLendingPlace.depositeLimitFUSDToken = 1000000.0
  }


 


    //function TokenLandCollection {
        self = {
            mFlow: 0,
            mFUSD: 0,
    
            myBorrowingmFlow: 0,
            myBorrowingmFUSD: 0
            }
    
            // init () {
            //     self.mFlow = 0.0
            //     self.mFUSD = 0.0
    
            //     self.myBorrowingmFlow = 0.0
            //     self.myBorrowingmFUSD = 0.0
            // }
       
            function addLiquidity(from) {
                //pre {
                    //only allow the type of from is Flow and FUSD Vault token
                ///}
    
                updatePriceAndInterest()//TokenLendingPlace.updatePriceAndInterest()
    
                if(from.type == "flow") {
                    let balance = from.balance
                    TokenLendingPlace.tokenVaultFlow.balance = TokenLendingPlace.tokenVaultFlow.balance + from.balance
                    self.mFlow = self.mFlow + (balance / TokenLendingPlace.mFlowtokenPrice)
                } else if(from.type == "usdc") {
                    let balance = from.balance
                    TokenLendingPlace.tokenVaultFUSD.balance = TokenLendingPlace.tokenVaultFUSD.balance + from.balance
                    self.mFUSD = self.mFUSD + (balance / TokenLendingPlace.mFUSDtokenPrice)
                }
                
                console.log("存錢: " + from.type + "  " + from.balance);
                //event
            }
    
            function removeLiquidity(_amount, _token) {
                updatePriceAndInterest()//TokenLendingPlace.updatePriceAndInterest()
    
                if(_token == 0) {
                    self.mFlow = self.mFlow - _amount
                    //let token1Vault <- TokenLendingPlace.tokenVaultFlow.withdraw(amount: (_amount * TokenLendingPlace.mFlowtokenPrice)) 
    
                    //event
                    //return <- token1Vault
                } else if(_token == 1) {
                    self.mFUSD = self.mFUSD - _amount
                    //let token1Vault <- TokenLendingPlace.tokenVaultFUSD.withdraw(amount: (_amount * TokenLendingPlace.mFUSDtokenPrice)) 
    
                    //event
                    //eturn <- token1Vault
                }
    
                //return <- TokenLendingPlace.tokenVaultFUSD.withdraw(amount: 0.0)
            }
    
            function getBorrowingPower() {
                
                //美元計價
                let FlowPower = (self.mFlow - self.myBorrowingmFlow) * TokenLendingPlace.mFlowtokenPrice * TokenLendingPlace.FlowTokenRealPrice
                let FUSDPower = (self.mFUSD - self.myBorrowingmFUSD) * TokenLendingPlace.mFUSDtokenPrice * TokenLendingPlace.FUSDTokenRealPrice 
    
                return FlowPower + FUSDPower
            }
    
            function getMaxBorrowingPower() {
                
                //美元計價
                let FlowPower = self.mFlow * TokenLendingPlace.mFlowtokenPrice * TokenLendingPlace.FlowTokenRealPrice 
                let FUSDPower = self.mFUSD * TokenLendingPlace.mFUSDtokenPrice * TokenLendingPlace.FUSDTokenRealPrice
    
                return FlowPower + FUSDPower
            }

            function getFlowBorrowingInterest() {
                return getFlowUtilizationRate() / 0.8 * (0.08 - 0) + 0.08
            }

            function getFUSDBorrowingInterest() { //Fake FUSD Rate
                return getFlowUtilizationRate() / 0.8 * (0.08 - 0) + 0.08
            }

            function getFlowLoanInterest() {
                return getFlowBorrowingInterest() * getFlowUtilizationRate()
            }

            function getFUSDLoanInterest() { //Fake FUSD Rate
                return getFlowBorrowingInterest() * getFlowUtilizationRate()
            }

            function getFlowUtilizationRate() {
                return TokenLendingPlace.mFlowBorrowAmountToken == 0 ? 0 : TokenLendingPlace.mFlowBorrowAmountToken * TokenLendingPlace.mFlowtokenPrice / (TokenLendingPlace.tokenVaultFlow.balance + TokenLendingPlace.mFlowBorrowAmountToken * TokenLendingPlace.mFlowtokenPrice)
            }
    
            function borrowFlow(_amount) {
                //pre {
                //    TokenLendingPlace.tokenVaultFlow.balance - TokenLendingPlace.FlowBorrowAmountToken > _amount: "Amount minted must be greater than zero"
                //    (self.getBorrowingPower() ?? 0.0 * 0.6) > (TokenLendingPlace.FlowTokenRealPrice * _amount) : "Amount minted must be greater than zero"
                //}
                
                updatePriceAndInterest()//TokenLendingPlace.updatePriceAndInterest()
    
                let realAmountofToken = _amount * TokenLendingPlace.mFlowBorrowingtokenPrice
                TokenLendingPlace.mFlowBorrowAmountToken = _amount + TokenLendingPlace.mFlowBorrowAmountToken
    
                self.myBorrowingmFlow = _amount + self.myBorrowingmFlow
    
                //let token1Vault <- TokenLendingPlace.tokenVaultFlow.withdraw(amount: realAmountofToken)
                //return <- token1Vault
                TokenLendingPlace.tokenVaultFlow.balance  = TokenLendingPlace.tokenVaultFlow.balance - realAmountofToken
                console.log("借出 Flow: " + realAmountofToken);
            }
    
            // //Repay
            function repayFlow(from){
                //unlock the borrowing power
    
                updatePriceAndInterest()//TokenLendingPlace.updatePriceAndInterest()
    
                TokenLendingPlace.mFlowBorrowAmountToken = TokenLendingPlace.mFlowBorrowAmountToken - (from.balance / TokenLendingPlace.mFlowBorrowingtokenPrice)
                self.myBorrowingmFlow = self.myBorrowingmFlow - (from.balance / TokenLendingPlace.mFlowBorrowingtokenPrice)
    
                //TokenLendingPlace.tokenVaultFlow.deposit(from: <- from )
                TokenLendingPlace.tokenVaultFlow.balance = TokenLendingPlace.tokenVaultFlow.balance + from.balance
            }
    
            // pub fun liquidateFlow(from: @FungibleToken.Vault): @FungibleToken.Vault{
                
            //     TokenLendingPlace.updatePriceAndInterest()
    
            //     //flow in flow out
            //     if(from.getType() == Type<@FlowToken.Vault>()) {
            //         TokenLendingPlace.FlowBorrowAmountToken = TokenLendingPlace.FlowBorrowAmountToken - from.balance
            //         self.myBorrowingmFlow = self.myBorrowingmFlow - (from.balance / TokenLendingPlace.mFlowtokenPrice)
    
            //         let repaymoney = from.balance * 1.05
    
            //         TokenLendingPlace.tokenVaultFlow.deposit(from: <- from)
    
            //         self.mFlow = self.mFlow - (repaymoney / TokenLendingPlace.mFlowtokenPrice)
    
            //         let token1Vault <- TokenLendingPlace.tokenVaultFlow.withdraw(amount: repaymoney)
            //         return <- token1Vault
            //     }
    
            //     //usdc in flow out
            //     if( from.getType() == Type<@FUSDToken.Vault>()) {
            //         TokenLendingPlace.FUSDBorrowAmountToken = TokenLendingPlace.FUSDBorrowAmountToken - from.balance
            //         self.myBorrowingmFUSD = self.myBorrowingmFUSD - (from.balance / TokenLendingPlace.mFUSDtokenPrice)
                    
            //         let repaymoney = from.balance * 1.05 / TokenLendingPlace.FlowTokenRealPrice
    
            //         TokenLendingPlace.tokenVaultFUSD.deposit(from: <- from)
    
            //         self.mFlow = self.mFlow - (repaymoney / TokenLendingPlace.mFlowtokenPrice)
    
            //         let tokenVault <- TokenLendingPlace.tokenVaultFlow.withdraw(amount: repaymoney)
            //         return <- tokenVault
            //     }
    
            //     return <- TokenLendingPlace.tokenVaultFlow.withdraw(amount: 0.0)
            // }
        //}
    
        // createCollection returns a new collection resource to the caller
        // pub fun createTokenLandCollection(): @TokenLandCollection {
        //     return <- create TokenLandCollection()
        // }

        init();

        TokenLendingPlace.tempBlock = 0

        addLiquidity({
            type: "flow",
            balance: 100
        });

        TokenLendingPlace.tempBlock = 1

        addLiquidity({
            type: "usdc",
            balance: 100
        });

        console.log("目前可借: " + getBorrowingPower() + " USD");
        console.log("最多可借: " + getMaxBorrowingPower() + " USD");
        console.log("Flow 借款利息: " + getFlowBorrowingInterest() + " USD");
        console.log("Flow 貸款利息: " + getFlowLoanInterest() + " USD");

        console.log("\n")

        TokenLendingPlace.tempBlock = 100
        borrowFlow(80);

        console.log("目前可借: " + getBorrowingPower() + " USD");
        console.log("最多可借: " + getMaxBorrowingPower() + " USD");
        console.log("Flow 借款利息: " + getFlowBorrowingInterest() + " USD");
        console.log("Flow 貸款利息: " + getFlowLoanInterest() + " USD");

        console.log("\n")

        TokenLendingPlace.tempBlock = 20000 //半天後左右
        updatePriceAndInterest()

        console.log("目前可借: " + getBorrowingPower() + " USD");
        console.log("最多可借: " + getMaxBorrowingPower() + " USD");
        console.log("Flow 借款利息: " + getFlowBorrowingInterest() + " USD");
        console.log("Flow 貸款利息: " + getFlowLoanInterest() + " USD");

        console.log("\n")
        console.log("\n")

        repayFlow({
            type: "flow",
            balance: 80
        });

        console.log("目前可借: " + getBorrowingPower() + " USD");
        console.log("最多可借: " + getMaxBorrowingPower() + " USD");
        console.log("最多欠款: " + (self.myBorrowingmFlow * TokenLendingPlace.mFlowtokenPrice) + " Flow");
        console.log("Flow 借款利息: " + getFlowBorrowingInterest() + " USD");
        console.log("Flow 貸款利息: " + getFlowLoanInterest() + " USD");
