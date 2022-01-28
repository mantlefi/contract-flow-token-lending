import TokenLendingPlace from 0x04

pub fun main(): {String: UFix64} {

    return {
        "flowBorrowApy": TokenLendingPlace.mFlowInterestRate,
        "fusdBorrowApy": TokenLendingPlace.mFUSDInterestRate,
        "bltBorrowApy": TokenLendingPlace.mBLTInterestRate
    }
}