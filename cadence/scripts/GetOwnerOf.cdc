import PxbeeMedia from 0x02

// This script return tokenOwner
pub fun main(tokenId: UInt64): String {
    let address = PxbeeMedia.getTokenOwner(id: tokenId)
    if address == nil {
        return ""
    }

    return address!.toString()
}