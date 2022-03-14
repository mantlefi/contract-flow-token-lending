import TokenLendingPlace from 0x04

pub fun main(): {String: UFix64} {

    return {
        "flowBorrowApy": TokenLendingPlace.mFlowBorrowingInterestRate,
        "usdcBorrowApy": TokenLendingPlace.mFiatTokenBorrowingInterestRate
    }
}