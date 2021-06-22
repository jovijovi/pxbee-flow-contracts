pub fun main(account: Address): UInt64 {
    return getAccount(account).storageUsed
}