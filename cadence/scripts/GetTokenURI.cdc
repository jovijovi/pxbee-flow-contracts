import PxbeeMedia from 0x02

pub fun main(tokenId: UInt64): String {
    let account = PxbeeMedia.getTokenOwner(id: tokenId)
    if account == nil {
        return ""
    }

    // Get the public collection of the owner of the token
    let collectionRef = getAccount(account!)
        .getCapability(PxbeeMedia.CollectionPublicPath)
        .borrow<&{PxbeeMedia.PxbeeCollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")

    // Borrow a reference to a specific NFT in the collection
    let nft = collectionRef.borrowPxbeeNFT(id: tokenId)
    if nft != nil {
        return nft!.tokenURI
    }

    return ""
}