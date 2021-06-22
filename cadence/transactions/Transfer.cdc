import NonFungibleToken from 0x01
import PxbeeMedia from 0x02

// This transaction transfers an NFT from one user's collection to another user's collection.
transaction(recipient: Address, withdrawID: UInt64) {
    // The field that will hold the NFT as it is being
    // transferred to the other account
    let transferToken: @NonFungibleToken.NFT

    prepare(owner: AuthAccount) {
        // Borrow a reference from the stored collection
        let collectionRef = owner.borrow<&PxbeeMedia.Collection>(from: PxbeeMedia.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")

        // Call the withdraw function on the sender's Collection
        // to move the NFT out of the collection
        self.transferToken <- collectionRef.withdraw(withdrawID: withdrawID)

        // Set token owner
        collectionRef.setTokenOwner(id: withdrawID, owner: recipient)
    }

    execute {
        // Get the recipient's public account object
        let recipientAccount = getAccount(recipient)

        // Get the Collection reference for the receiver
        // getting the public capability and borrowing a reference from it
        let receiverRef = recipientAccount.getCapability(PxbeeMedia.CollectionPublicPath)
            .borrow<&{PxbeeMedia.PxbeeCollectionPublic}>()
            ?? panic("Could not borrow a reference to the receiver's collection")

        // Deposit the NFT in the receivers collection
        receiverRef.deposit(token: <-self.transferToken)

        log("NFT transferred successfully")
    }
}
