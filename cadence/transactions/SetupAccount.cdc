import PxbeeMedia from 0x02

// This transaction is what an account would run
// to set itself up to receive NFTs
transaction {
    prepare(acct: AuthAccount) {
        // Return early if the account already has a collection
        if acct.borrow<&PxbeeMedia.Collection>(from: PxbeeMedia.CollectionStoragePath) != nil {
            log("PxbeeMedia.CollectionStoragePath already exist, return directly")
            return
        }

        // Create a new empty collection
        let collection <- PxbeeMedia.createEmptyCollection()

        // save it to the account
        acct.save(<-collection, to: PxbeeMedia.CollectionStoragePath)

        // create a public capability for the collection
        acct.link<&{PxbeeMedia.PxbeeCollectionPublic}>(
            PxbeeMedia.CollectionPublicPath,
            target: PxbeeMedia.CollectionStoragePath
        )

        log("Capability created")
    }
}