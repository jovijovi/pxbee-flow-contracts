import PxbeeMedia from 0x02

// This script return tokenId
pub fun main(contentHash: String): String {
    let tokenId = PxbeeMedia.getTokenIdByContentHash(contentHash: contentHash)
    if tokenId == nil {
        return ""
    }

    return tokenId!.toString()
}