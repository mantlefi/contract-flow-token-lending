import TokenLendPlace from 0x04

pub fun main(): {String: UFix64} {

    return {"flowBorrowApy":TokenLendPlace.mFlowInterestRate,"fusdBorrowApy":TokenLendPlace.mFUSDInterestRate,"bltBorrowApy":TokenLendPlace.mBLTInterestRate}
}