// Description: Media NFT Contract
// Version: v0.1.10
// Author: PXBEE

import NonFungibleToken from 0x01

pub contract PXBEE: NonFungibleToken {
	// NFT total supply
	pub var totalSupply: UInt64

	// Minted NFTs id
	pub var mintedNFTs: {UInt64: Bool}

	// Token owners
	pub var tokenOwners: {UInt64: Address}

	// Content hashes
	pub var contentHashes: {String: UInt64}

	// Token content hashes
	pub var tokenContentHashes: {UInt64: String}

	// Token creators
	pub var tokenCreators: {UInt64: Address}

	// emitted when the contract is created
	pub event ContractInitialized()

	// emitted when a NFT is withdrawn from a collection
	pub event Withdraw(id: UInt64, from: Address?)

	// emitted when a NFT is deposited into a collection
	pub event Deposit(id: UInt64, to: Address?)

	// The resource that represents the Pxbee NFTs
	pub resource NFT: NonFungibleToken.INFT {
		// global unique ID
		pub let id: UInt64

		// metadata
		pub var metadata: {String: String}

		// tokenURI
		pub var tokenURI: String

		init(initID: UInt64, initTokenURI: String) {
			self.id = initID
			self.metadata = {}
			self.tokenURI = initTokenURI
		}

		// setTokenURI set tokenURI
		pub fun setTokenURI(tokenURI: String) {
			self.tokenURI = tokenURI
		}
	}

	// This is the interface that users can cast their NFT Collection as to allow others to deposit NFTs into their collection.
	pub resource interface PxbeeCollectionPublic {
		pub fun deposit(token: @NonFungibleToken.NFT)
		pub fun getIDs(): [UInt64]
		pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
		pub fun borrowPxbeeNFT(id: UInt64): &PXBEE.NFT? {
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
			let token <- token as! @PXBEE.NFT

			let id: UInt64 = token.id

			// Check if owner has the NFT
			if self.ownedNFTs[id] != nil {
				destroy token
				return
			}

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
		pub fun borrowPxbeeNFT(id: UInt64): &PXBEE.NFT? {
			if self.ownedNFTs[id] != nil {
				let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
				return ref as! &PXBEE.NFT
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

		// updateTokenURI update NFT's tokenURI
		pub fun updateTokenURI(id: UInt64, tokenURI: String): Bool {
			if self.ownedNFTs[id] != nil {
				let nftRef = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
				let pxbeeNFT = nftRef as! &PXBEE.NFT
				pxbeeNFT.setTokenURI(tokenURI: tokenURI)
				return true
			}

			return false
		}

		// burn NFT
		pub fun burn(id: UInt64): Bool {
			if self.ownedNFTs[id] != nil {
				// remove token owner
				PXBEE.tokenOwners.remove(key: id)
				// remove token creator
				PXBEE.tokenCreators.remove(key: id)
				// remove token content hash
				let hash = PXBEE.tokenContentHashes[id]!
				PXBEE.contentHashes.remove(key: hash)
				PXBEE.tokenContentHashes.remove(key: id)
				// remove mint nft
				PXBEE.mintedNFTs.remove(key: id)
				// count totalSupply
				PXBEE.totalSupply = PXBEE.totalSupply - 1 as UInt64
				return true
			}

			return false
		}

		destroy() {
			destroy self.ownedNFTs
		}
	}

	// public function that anyone can call to create a new empty collection
	pub fun createEmptyCollection(): @NonFungibleToken.Collection {
		return <- create Collection()
	}

	// Resource that an admin or something similar would own to be
	// able to mint new NFTs
	pub resource NFTMinter {
		// mintNFT mints a new NFT with the specified ID in params
		// and deposit it in the recipients collection using their collection reference
		pub fun mintNFT(recipient: &{PxbeeCollectionPublic}, id: UInt64, hash: String, tokenURI: String,
			creatorAddress: Address, ownerAddress: Address): Bool {
			if PXBEE.mintedNFTs[id] != nil {
				return false
			} else if PXBEE.contentHashes[hash] != nil {
				return false
			}

			// create a new NFT with TokenID & TokenURI
			var newNFT <- create NFT(initID: id, initTokenURI: tokenURI)

			// deposit it in the recipient's account using their reference
			recipient.deposit(token: <-newNFT)

			// Update tokenOwners
			PXBEE.tokenOwners.insert(key: id, ownerAddress)

			// Update tokenCreators
			PXBEE.tokenCreators.insert(key: id, creatorAddress)

			// Update content hashes
			PXBEE.contentHashes.insert(key: hash, id)

			// Update token content hashes
			PXBEE.tokenContentHashes.insert(key: id, hash)

			// Update minted NFT
			PXBEE.mintedNFTs.insert(key: id, true)

			// Update totalSupply
			PXBEE.totalSupply = PXBEE.totalSupply + 1 as UInt64

			return true
		}
	}

	init() {
		// Initialize the fields
		self.totalSupply = 0
		self.mintedNFTs = {}
		self.contentHashes = {}
		self.tokenContentHashes = {}
		self.tokenOwners = {}
		self.tokenCreators = {}

		// Create a Collection resource and save it to storage
		self.account.save(<- create Collection(), to: /storage/NFTCollection)

		// create a public capability for the collection
		self.account.link<&{PxbeeCollectionPublic}>(
			/public/NFTCollection,
			target: /storage/NFTCollection
		)

		// Create a Minter resource and save it to storage
		self.account.save(<- create NFTMinter(), to: /storage/NFTMinter)

		emit ContractInitialized()
	}
}
