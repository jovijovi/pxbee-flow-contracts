import PxbeeMedia from 0x02

// This script return tokenId in tokenOwners
pub fun main(index: UInt64): String {
    let tokenId = PxbeeMedia.getTokenIdByIndex(index: index)
    if tokenId == nil {
        return ""
    }

    return tokenId!.toString()
}