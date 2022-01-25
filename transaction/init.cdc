import FlowToken from 0x02
import FungibleToken from 0x01
import TokenLendPlace from 0x04


// This transaction is a template for a transaction that
// could be used by anyone to send tokens to another account
// that owns a Vault
transaction() {
  prepare(acct: AuthAccount) {
   if acct.borrow<&AnyResource{TokenLendPlace.TokenLandPublic}>(from: TokenLendPlace.CollectionStoragePath) == nil {
            let lendingPlace <- TokenLendPlace.createTokenLandCollection()
            acct.save(<-lendingPlace, to: /storage/TokenLendPlace)
            acct.link<&TokenLendPlace.TokenLandCollection{TokenLendPlace.TokenLandPublic}>(TokenLendPlace.CollectionPublicPath, target: TokenLendPlace.CollectionStoragePath)
        }
  }

  execute {
  }
}
 