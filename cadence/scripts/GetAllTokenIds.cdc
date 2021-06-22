import PxbeeMedia from 0x02

// This transaction returns an array of all the NFT ids in the collection
pub fun main(account: Address): [UInt64] {
    // Get the public account object for account
    let nftOwner = getAccount(account)

    // Find the public Receiver capability for their Collection
    let collectionRef = getAccount(account)
        .getCapability(PxbeeMedia.CollectionPublicPath)
        .borrow<&{PxbeeMedia.PxbeeCollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")

    return collectionRef.getIDs()
}