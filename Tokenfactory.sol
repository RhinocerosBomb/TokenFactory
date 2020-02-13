pragma solidity ^0.5.16;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

contract ArtworkToken is ERC721 {
    struct Artwork {
        uint256 artistId;
        string  name;
    }
    
    mapping(uint256 => Artwork) hashIPFSToArtwork;
    
    address owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }
    
    function createArtwork(uint256 ipfsHash, string calldata artName, uint256 artistId, address originalOwner) external onlyOwner returns(uint256) {
        _safeMint(originalOwner, ipfsHash);
        hashIPFSToArtwork[ipfsHash] = Artwork(artistId, artName);
        return ipfsHash;
    }
    
    function artworkExists(uint hashIPFS) external view onlyOwner returns (bool) {
        return _exists(hashIPFS);
    }
    
    function() external {
        revert('This contract does not take ETH');
    }

}

contract ArtistToken is ERC721 {
    uint256 totalArtists;
    address artworkFactoryAddress;

    constructor(address artworkFactory) public {
        require(artworkFactory != address(0));
        artworkFactoryAddress = address(artworkFactory);
    }
    
    function createArtist() public returns (uint256) {
        uint256 artistId = totalArtists;
        _safeMint(msg.sender, artistId);
        totalArtists = totalArtists.add(1);
        return artistId;
    }
    
    function createArtwork(uint256 artistId, uint256 ipfsHash, string memory artName, address originalOwner) public {
        require(ownerOf(artistId) == msg.sender, 'Cannot create artwork for an artist that you dont own');
        ArtworkToken(artworkFactoryAddress).createArtwork(ipfsHash, artName, artistId, originalOwner);
    }
    
    function checkArtwork(uint hashIPFS) public view returns(bool) {
        return ArtworkToken(artworkFactoryAddress).artworkExists(hashIPFS);
    }
    
    function() external {
        revert('This contract does not take ETH');
    }
}