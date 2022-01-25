import FungibleToken from 0x01
import BloctoToken from 0x05

pub fun main(address: Address): UFix64 {
    let account = getAccount(address)

    let vaultRef = account.getCapability(/public/bloctoTokenBalance)!
        .borrow<&BloctoToken.Vault{FungibleToken.Balance}>()
        ?? panic("Could not borrow Balance reference to the Vault")

    return vaultRef.balance
}