import PxbeeMedia from 0x02

// This script return tokenContentHash
pub fun main(tokenId: UInt64): String {
    let tokenContentHash = PxbeeMedia.getTokenContentHash(id: tokenId)
    if tokenContentHash == nil {
        return ""
    }

    return tokenContentHash!
}