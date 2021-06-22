import PxbeeMedia from 0x02

// This script return tokenCreator
pub fun main(tokenId: UInt64): String {
    let address = PxbeeMedia.getTokenCreator(id: tokenId)
    if address == nil {
        return ""
    }

    return address!.toString()
}