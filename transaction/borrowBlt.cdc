import BloctoToken from 0x05
import TokenLendingPlace from 0x04

transaction(amount: UFix64) {

    // Temporary vault object which holds the transferred balance
    var vaultRef: &BloctoToken.Vault
    var lendingPlace: &TokenLendingPlace.TokenLendingCollection

    prepare(acct: AuthAccount) {
        if acct.borrow<&AnyResource{TokenLendingPlace.TokenLendingPublic}>(from: TokenLendingPlace.CollectionStoragePath) == nil {
            let lendingPlace <- TokenLendingPlace.createTokenLendingCollection()
            acct.save(<-lendingPlace, to: TokenLendingPlace.CollectionStoragePath)
            acct.link<&TokenLendingPlace.TokenLendingCollection{TokenLendingPlace.TokenLendingPublic}>(TokenLendingPlace.CollectionPublicPath, target: TokenLendingPlace.CollectionStoragePath)
        }

        // Borrow a reference of valut and withdraw tokens, then call the deposit function with that reference
        self.vaultRef = acct.borrow<&BloctoToken.Vault>(from: /storage/bloctoTokenVault)
            ?? panic("Could not borrow a reference to the owner's BLT vault")

        self.lendingPlace = acct.borrow<&TokenLendingPlace.TokenLendingCollection>(from: TokenLendingPlace.CollectionStoragePath)
            ?? panic("Could not borrow TokenLendingPlace reference")
    }

    execute {
        var vault <- self.lendingPlace.borrowBLT(_amount: amount)

        self.vaultRef.deposit(from: <-vault)

        log("Borrow succeeded")
    }
}
 