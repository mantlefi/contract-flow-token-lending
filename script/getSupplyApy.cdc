import TokenLendingPlace from 0x04

pub fun main(): {String: UFix64} {
    return {"flowSupplyApy":TokenLendingPlace.mFlowInterestRate * TokenLendingPlace.getFlowUtilizationRate(),"fusdSupplyApy":TokenLendingPlace.mFUSDInterestRate * TokenLendingPlace.getFUSDUtilizationRate(),"bltSupplyApy":TokenLendingPlace.mBLTInterestRate * TokenLendingPlace.getBLTUtilizationRate()}
}