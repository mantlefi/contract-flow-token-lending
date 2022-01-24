import TokenLendPlace from 0x04

pub fun main(): {String: UFix64} {
    return {"flowSupplyApy":TokenLendPlace.mFlowInterestRate * TokenLendPlace.getFlowBorrowPercent(),"fusdSupplyApy":TokenLendPlace.mFUSDInterestRate * TokenLendPlace.getFUSDBorrowPercent(),"bltSupplyApy":TokenLendPlace.mBLTInterestRate * TokenLendPlace.getBltBorrowPercent()}
}