import FungibleToken from 0x01
import FlowToken from 0x02

pub fun main(account: Address): UFix64 {

    let vaultRef = getAccount(account).getCapability(/public/flowTokenBalance)
        .borrow<&FlowToken.Vault{FungibleToken.Balance}>()
        ?? panic("Could not borrow balance reference to the Vault")

    return vaultRef.balance
}