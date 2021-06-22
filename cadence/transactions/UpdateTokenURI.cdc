import PxbeeMedia from 0x02

transaction(tokenId: UInt64, tokenURI: String) {
    prepare(acct: AuthAccount) {
        // Borrow a reference from the stored collection
        let collectionRef = acct.borrow<&PxbeeMedia.Collection>(from: PxbeeMedia.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")

        // Set tokenURI
        if !collectionRef.setTokenURI(id: tokenId, tokenURI: tokenURI) {
            log("Update tokenURI failed")
            return
        }

        log("Update tokenURI successfully")
    }
}
