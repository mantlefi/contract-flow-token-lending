import BloctoToken from 0x05
import TokenLendingPlace from 0x04

transaction(amount: UFix64) {

    // Temporary vault object which holds the transferred balance
    var temporaryVault: @BloctoToken.Vault
    var lendingPlace: &TokenLendingPlace.TokenLendingCollection

    prepare(acct: AuthAccount) {
        if acct.borrow<&AnyResource{TokenLendingPlace.TokenLendingPublic}>(from: TokenLendingPlace.CollectionStoragePath) == nil {
            let lendingPlace <- TokenLendingPlace.createTokenLendingCollection()
            acct.save(<-lendingPlace, to: TokenLendingPlace.CollectionStoragePath)
            acct.link<&TokenLendingPlace.TokenLendingCollection{TokenLendingPlace.TokenLendingPublic}>(TokenLendingPlace.CollectionPublicPath, target: TokenLendingPlace.CollectionStoragePath)
        }

        // Borrow a reference of valut and withdraw tokens, then call the withdraw function with that reference
        let vaultRef = acct.borrow<&BloctoToken.Vault>(from: /storage/bloctoTokenVault)
            ?? panic("Could not borrow a reference to the owner's BLT vault")
        
        self.temporaryVault <- vaultRef.withdraw(amount: amount) as! @BloctoToken.Vault

        self.lendingPlace = acct.borrow<&TokenLendingPlace.TokenLendingCollection>(from: TokenLendingPlace.CollectionStoragePath)
            ?? panic("Could not borrow TokenLendingPlace reference")
    }

    execute {
        self.lendingPlace.addLiquidity(from: <-self.temporaryVault)

        log("deposit succeeded")
    }
}
 