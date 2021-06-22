import PxbeeMedia from 0x02

// This script reads metadata about an NFT in a user's collection
pub fun main(account: Address, tokenId: UInt64): &PxbeeMedia.NFT? {
    // Get the public collection of the owner of the token
    let collectionRef = getAccount(account)
        .getCapability(PxbeeMedia.CollectionPublicPath)
        .borrow<&{PxbeeMedia.PxbeeCollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")

    // Borrow a reference to a specific NFT in the collection
    let nft = collectionRef.borrowPxbeeNFT(id: tokenId)

    return nft
}