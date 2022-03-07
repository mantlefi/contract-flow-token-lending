import FlowToken from 0xf8d6e0586b0a20c7
import TokenLendingPlace from 0xf8d6e0586b0a20c7

transaction(amount: UFix64) {
  
    // Temporary vault object which holds the transferred balance
    var temporaryVault: @FlowToken.Vault
    var lendingPlace: &TokenLendingPlace.TokenLendingCollection

    prepare(acct: AuthAccount) {
        if acct.borrow<&AnyResource{TokenLendingPlace.TokenLendingPublic}>(from: TokenLendingPlace.CollectionStoragePath) == nil {
            let lendingPlace <- TokenLendingPlace.createTokenLendingCollection()
            acct.save(<-lendingPlace, to: TokenLendingPlace.CollectionStoragePath)
            acct.link<&TokenLendingPlace.TokenLendingCollection{TokenLendingPlace.TokenLendingPublic}>(TokenLendingPlace.CollectionPublicPath, target: TokenLendingPlace.CollectionStoragePath)
        }
        
        // Borrow a reference of valut and withdraw tokens, then call the withdraw function with that reference
        let vaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Could not borrow a reference to the owner's vault")
        
        self.temporaryVault <- vaultRef.withdraw(amount: amount) as! @FlowToken.Vault

        self.lendingPlace = acct.borrow<&TokenLendingPlace.TokenLendingCollection>(from: TokenLendingPlace.CollectionStoragePath)
            ?? panic("Could not borrow TokenLendingPlace reference")
    }

    execute {
        self.lendingPlace.addLiquidity(from: <-self.temporaryVault)

        log("Deposit succeeded")
    }
}
 