import TokenLendingPlace from 0x04

pub fun main(): {String: UFix64} {
    return {"flowSupplyApy":TokenLendingPlace.mFlowInterestRate * TokenLendingPlace.getFlowBorrowRate(),"fusdSupplyApy":TokenLendingPlace.mFUSDInterestRate * TokenLendingPlace.getFUSDBorrowRate(),"bltSupplyApy":TokenLendingPlace.mBLTInterestRate * TokenLendingPlace.getBltBorrowRate()}
}