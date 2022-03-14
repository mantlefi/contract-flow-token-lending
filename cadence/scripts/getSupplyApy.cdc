import TokenLendingPlace from 0x04

pub fun main(): {String: UFix64} {
    return {
        "flowSupplyApy":TokenLendingPlace.mFlowInterestRate,
        "usdcSupplyApy":TokenLendingPlace.mFiatTokenInterestRate
    }
}