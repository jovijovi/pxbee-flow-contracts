import PxbeeMedia from 0x02

// This transaction checks if an NFT exists in the storage of the given account
// by trying to borrow from it
transaction {
    prepare(acct: AuthAccount) {
        if acct.borrow<&PxbeeMedia.Collection>(from: PxbeeMedia.CollectionStoragePath) != nil {
            log("The NFTCollection exists!")
        } else {
            log("No NFTCollection found!")
        }
    }
}
