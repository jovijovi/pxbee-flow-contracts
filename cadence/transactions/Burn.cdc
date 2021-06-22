import PxbeeMedia from 0x02

transaction(tokenId: UInt64) {
    prepare(acct: AuthAccount) {
        // Borrow a reference from the stored collection
        let collectionRef = acct.borrow<&PxbeeMedia.Collection>(from: PxbeeMedia.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")

        collectionRef.burn(id: tokenId)

        log("Burn NFT successfully")
    }
}