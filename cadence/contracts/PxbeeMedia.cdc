// PxbeeMedia NFT Contract v0.2.0

import NonFungibleToken from 0x01

pub contract PxbeeMedia: NonFungibleToken {
	// -----------------------------------------------------------------------
	// Contract Events
	// -----------------------------------------------------------------------

	// Emitted when the contract is created
	pub event ContractInitialized()

	// Emitted when a NFT is withdrawn from a collection
	pub event Withdraw(id: UInt64, from: Address?)

	// Emitted when a NFT is deposited into a collection
	pub event Deposit(id: UInt64, to: Address?)

	// Emitted when a NFT is minted
	pub event Minted(id: UInt64)

	// Emitted when a NFT is destroyed
	pub event Destroyed(id: UInt64)

	// -----------------------------------------------------------------------
	// Named Paths
	// -----------------------------------------------------------------------

	pub let CollectionStoragePath: StoragePath
	pub let CollectionPublicPath: PublicPath
	pub let MinterStoragePath: StoragePath

	// -----------------------------------------------------------------------
	// Contract-level fields
	// -----------------------------------------------------------------------

	// NFT total supply
	pub var totalSupply: UInt64

	// Mint counter
	pub var mintCounter: UInt64

	// Content hashes
	access(self) var contentHashes: {String: UInt64}

	// Token ledger
	access(self) var tokenLedger: {UInt64: TokenInfo}

	// -----------------------------------------------------------------------
	// Contract-level Composite Type definitions
	// -----------------------------------------------------------------------

	// TokenInfo struct
	pub struct TokenInfo {
		pub let id: UInt64
		pub let creator: Address

		pub var owner: Address
		pub var contentHash: String

		init(id: UInt64, owner: Address, creator: Address, contentHash: String) {
			self.id = id
			self.creator = creator
			self.owner = owner
			self.contentHash = contentHash
		}

		pub fun setOwner(owner: Address) {
			self.owner = owner
		}

		pub fun setContentHash(contentHash: String) {
			self.contentHash = contentHash
		}
	}

	// The resource that represents the Pxbee NFTs
	pub resource NFT: NonFungibleToken.INFT {
		// Global unique ID
		pub let id: UInt64

		// NFT creator
		pub let creator: Address

		// Metadata
		pub var metadata: {String: String}

		// TokenURI
		pub var tokenURI: String

		init(id: UInt64, creator: Address, tokenURI: String) {
			self.id = id
			self.creator = creator
			self.tokenURI = tokenURI
			self.metadata = {}
		}

		// If the NFT is destroyed, emit an event
		destroy() {
			emit Destroyed(id: self.id)
		}

		// Set tokenURI
		pub fun setTokenURI(tokenURI: String) {
			self.tokenURI = tokenURI
		}

		// Set metadata
		pub fun setMetadata(metadata: {String: String}) {
			self.metadata = metadata
		}
	}

	// This is the interface that users can cast their NFT Collection as to allow others to deposit NFTs into their collection.
	pub resource interface PxbeeCollectionPublic {
		pub fun deposit(token: @NonFungibleToken.NFT)
		pub fun getIDs(): [UInt64]
		pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
		pub fun borrowPxbeeNFT(id: UInt64): &PxbeeMedia.NFT? {
			// If the result isn't nil, the id of the returned reference
			// should be the same as the argument to the function
			post {
				(result == nil) || (result?.id == id):
					"Cannot borrow Pxbee NFT reference: The ID of the returned reference is incorrect"
			}
		}
		pub fun isOwned(id: UInt64): Bool
	}

	pub resource Collection: PxbeeCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
		// dictionary of NFT conforming tokens
		// NFT is a resource type with an `UInt64` ID field
		pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

		init () {
			self.ownedNFTs <- {}
		}

		// withdraw removes an NFT from the collection and moves it to the caller
		pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
			let token <- self.ownedNFTs.remove(key: withdrawID)
				?? panic("Cannot withdraw: NFT does not exist in the collection")

			emit Withdraw(id: token.id, from: self.owner?.address)

			return <-token
		}

		// deposit takes a NFT and adds it to the collections dictionary
		// and adds the ID to the id array
		pub fun deposit(token: @NonFungibleToken.NFT) {
			pre {
				// Check if owner has the NFT
				self.ownedNFTs[token.id] == nil : "NFT already exists in ownedNFTs"
			}

			let token <- token as! @PxbeeMedia.NFT

			let id: UInt64 = token.id

			// add the new token to the dictionary which removes the old one
			let oldToken <- self.ownedNFTs[id] <- token

			if self.owner?.address != nil {
				emit Deposit(id: id, to: self.owner?.address)
			}

			destroy oldToken
		}

		// getIDs returns an array of the IDs that are in the collection
		pub fun getIDs(): [UInt64] {
			return self.ownedNFTs.keys
		}

		// borrowNFT gets a reference to an NFT in the collection
		// so that the caller can read its metadata and call its methods
		pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
			return &self.ownedNFTs[id] as &NonFungibleToken.NFT
		}

		// borrowPxbeeNFT Returns a borrowed reference to a PxbeeNFT in the collection
		// so that the caller can read data and call methods from it
		// Paras: id: The ID of the NFT to get the reference for
		// Returns: A reference to the PxbeeNFT
		pub fun borrowPxbeeNFT(id: UInt64): &PxbeeMedia.NFT? {
			if self.ownedNFTs[id] != nil {
				let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
				return ref as! &PxbeeMedia.NFT
			}
			else {
				return nil
			}
		}

		// isOwned returns if the account has the NFT
		pub fun isOwned(id: UInt64): Bool {
			if self.ownedNFTs[id] != nil {
				return true
			}

			return false
		}

		// Set NFT's tokenURI
		pub fun setTokenURI(id: UInt64, tokenURI: String): Bool {
			if self.ownedNFTs[id] != nil {
				let nftRef = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
				let pxbeeNFT = nftRef as! &PxbeeMedia.NFT
				pxbeeNFT.setTokenURI(tokenURI: tokenURI)
				return true
			}

			return false
		}

		// Set token owner (only NFTMinter account can do this)
		pub fun setTokenOwner(id: UInt64, owner: Address) {
			pre {
				PxbeeMedia.tokenLedger[id] != nil : "NFT not exists"
			}

			PxbeeMedia.tokenLedger[id]?.setOwner(owner: owner)
		}

		// burn NFT
		pub fun burn(id: UInt64) {
			pre {
				self.ownedNFTs[id] != nil : "not owned NFT";
			}

			// Set contract fields
			let hash = PxbeeMedia.tokenLedger[id]!.contentHash
			PxbeeMedia.contentHashes.remove(key: hash)
			PxbeeMedia.tokenLedger.remove(key: id)
			PxbeeMedia.totalSupply = PxbeeMedia.totalSupply - 1 as UInt64

			// Withdraw token
			let token <- self.withdraw(withdrawID: id)

			// Destroy token
			destroy token
		}

		destroy() {
			destroy self.ownedNFTs
		}
	}

	// Resource that an admin or something similar would own to be
	// able to mint new NFTs
	pub resource NFTMinter {
		// mintNFT mints a new NFT with the specified ID in params
		// and deposit it in the recipients collection using their collection reference
		pub fun mintNFT(recipient: &{PxbeeCollectionPublic}, id: UInt64, hash: String, tokenURI: String,
			creatorAddress: Address, ownerAddress: Address): Bool {
			pre {
				PxbeeMedia.tokenLedger[id] == nil : "NFT already exists"
				PxbeeMedia.contentHashes[hash] == nil : "NFT content hash already exists"
			}

			// create a new NFT with TokenID & TokenURI
			var newNFT <- create NFT(id: id, creator: creatorAddress, tokenURI: tokenURI)

			// deposit it in the recipient's account using their reference
			recipient.deposit(token: <-newNFT)

			// Set contract fields
			PxbeeMedia.tokenLedger[id] = TokenInfo(id: id, owner: ownerAddress, creator: creatorAddress, contentHash: hash)
			PxbeeMedia.contentHashes.insert(key: hash, id)
			// Mint counter increase 1
			PxbeeMedia.mintCounter = PxbeeMedia.mintCounter + 1 as UInt64
			// Total supply increase 1
			PxbeeMedia.totalSupply = PxbeeMedia.totalSupply + 1 as UInt64

			emit Minted(id: id)

			return true
		}
	}

	// -----------------------------------------------------------------------
	// Contract-level function definitions
	// -----------------------------------------------------------------------

	// public function that anyone can call to create a new empty collection
	pub fun createEmptyCollection(): @NonFungibleToken.Collection {
		return <- create Collection()
	}

	// Get token owner address from token ledger
	pub fun getTokenOwner(id: UInt64): Address? {
		return PxbeeMedia.tokenLedger[id]?.owner
	}

	// Get token content hash form token ledger
	pub fun getTokenContentHash(id: UInt64): String? {
		return PxbeeMedia.tokenLedger[id]?.contentHash
	}

	// Get token creator from token ledger
	pub fun getTokenCreator(id: UInt64): Address? {
		return PxbeeMedia.tokenLedger[id]?.creator
	}

	// Get tokenId by content hash from token ledger
	pub fun getTokenIdByContentHash(contentHash: String): UInt64? {
		return PxbeeMedia.contentHashes[contentHash]
	}

	// Get tokenId by index from token ledger
	pub fun getTokenIdByIndex(index: UInt64): UInt64? {
		return PxbeeMedia.tokenLedger.keys[index]
	}

	// -----------------------------------------------------------------------
	// Initialization function
	// -----------------------------------------------------------------------

	init() {
		// Initialize named paths
		self.CollectionStoragePath = /storage/NFTCollection
		self.CollectionPublicPath = /public/NFTCollection
		self.MinterStoragePath = /storage/NFTMinter

		// Initialize the fields
		self.totalSupply = 0
		self.mintCounter = 0
		self.tokenLedger = {}
		self.contentHashes = {}

		// Create a Minter resource and save it to storage
		self.account.save(<- create NFTMinter(), to: self.MinterStoragePath)

		emit ContractInitialized()
	}
}
