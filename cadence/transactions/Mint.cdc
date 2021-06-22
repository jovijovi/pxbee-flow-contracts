import PxbeeMedia from 0x02

// This script uses the NFTMinter resource to mint a new NFT
// It must be run with the account that has the minter resource
// stored in /storage/NFTMinter
transaction(recipient: Address, tokenId: UInt64, contentHash: String, tokenURI: String) {
    // local variable for storing the minter reference
    let minter: &PxbeeMedia.NFTMinter

    // local variable for creator
    let creator: Address

    prepare(signer: AuthAccount) {
        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&PxbeeMedia.NFTMinter>(from: PxbeeMedia.MinterStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")
        self.creator = signer.address
    }

    execute {
        // Borrow the recipient's public NFT collection reference
        let receiver = getAccount(recipient)
            .getCapability(PxbeeMedia.CollectionPublicPath)
            .borrow<&{PxbeeMedia.PxbeeCollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

        // Mint the NFT and deposit it to the recipient's collection
        let result = self.minter.mintNFT(recipient: receiver, id: tokenId, hash: contentHash, tokenURI: tokenURI,
            creatorAddress: self.creator, ownerAddress: recipient)
        if !result {
            log("Skip mint")
        } else {
            log("Mint NFT successfully")
        }
    }
}
