//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";//implementation of the ERC721 standard
import "@openzeppelin/contracts/utils/Counters.sol";//provides counters that can only be incremented or decremented by one
import "@openzeppelin/contracts/access/Ownable.sol";//set up access control
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("MyNFT", "NFT") {}
    //address recipient specifies the address that will receive your freshly minted NFT
    //string memory tokenURI is a string that should resolve to a JSON document that describes the NFT's metadata.
    //mintNFT calls some methods from the inherited ERC-721 library, and ultimately returns a number that represents the ID of the freshly minted NFT

    function mintNFT(address recipient, string memory tokenURI)
        public onlyOwner
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
}
