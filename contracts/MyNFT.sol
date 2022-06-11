    //"SPDX-License-Identifier: UNLICENSED"
    pragma solidity ^0.8.0;

    import "@openzeppelin/contracts/token/ERC721/ERC721.sol";//implementation of the ERC721 standard
    import "@openzeppelin/contracts/utils/Counters.sol";//provides counters that can only be incremented or decremented by one
    import "@openzeppelin/contracts/access/Ownable.sol";//set up access control
    import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
    import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
    import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";





    contract MyNFT is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable {
        using Counters for Counters.Counter;

        Counters.Counter private _tokenIds;

        bool private _transferable = true;
        bool private _mintable = true;
        bool private _burnable = true;
        bool private _frozen = true;


        //具有转账功能的智能合约的 constructor 必须显式的指定为 payable。
        //
        constructor() ERC721("MyNFT", "NFT") payable {}
        //address recipient specifies the address that will receive your freshly minted NFT
        //string memory tokenURI is a string that should resolve to a JSON document that describes the NFT's metadata.
        //mintNFT calls some methods from the inherited ERC-721 library, and ultimately returns a number that represents the ID of the freshly minted NFT

        function mintNFT()
            public 
            returns (uint256)
        {
            require(_mintable, "the NFT is not mintable");
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            _safeMint(msg.sender, newItemId);
            return newItemId;
        }

    
        function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _setTokenURI(tokenId, _tokenURI);
        }   

        function _beforeTokenTransfer(address from, address to, uint256 tokenId)
            internal
            override(ERC721, ERC721Enumerable)
        {
            super._beforeTokenTransfer(from, to, tokenId);
        }

        function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
            super._burn(tokenId);
        }

        function burnNFT(uint256 tokenId) public {
            require(_burnable == true, "The nft is not burnable");
            _burn(tokenId);
        }

        function tokenURI(uint256 tokenId)
            public
            view
            override(ERC721, ERC721URIStorage)
            returns (string memory)
        {
            return super.tokenURI(tokenId);
        }

        function supportsInterface(bytes4 interfaceId)
            public
            view
            override(ERC721, ERC721Enumerable)
            returns (bool)
        {
            return super.supportsInterface(interfaceId);
        }


        // Added isTransferable only
        function transferFrom(
            address from,
            address to,
            uint256 tokenId
        ) public override isTransferable {
            //solhint-disable-next-line max-line-length
            require(
                _isApprovedOrOwner(_msgSender(), tokenId),
                "ERC721: transfer caller is not owner nor approved"
            );
            require(_transferable == true, "The nft is not burnable");


            _transfer(from, to, tokenId);
        }

        // Added isTransferable only
        function safeTransferFrom(
            address from,
            address to,
            uint256 tokenId,
            bytes memory _data
        ) public override isTransferable {
            require(
                _isApprovedOrOwner(_msgSender(), tokenId),
                "ERC721: transfer caller is not owner nor approved"
            );
            require(_transferable == true, "The nft is not burnable");

            _safeTransfer(from, to, tokenId, _data);
        }

        modifier isTransferable() {
            require(_transferable == true, "Memberships: not transferable");
            _;
        }

        function getTransferable() public view returns (bool) {
            return _transferable;
        }

        function flipTransferable() public onlyOwner {
            require(_frozen == false, "the nft is frozen");
            _transferable = !_transferable;
        }
        
         // if the condition is satisfied, the function will run, otherwise it will throw exception (modifier)

        function getBurnable() public view returns (bool) {
            return _burnable;
        }

        function flipBurnable() public onlyOwner {
            require(_frozen == false, "the nft is frozen");
            _burnable = !_burnable;
        }

        function getMintable() public view returns (bool) {
            return _mintable;
        }

        function flipMintable() public onlyOwner {
            require(_frozen == false, "the nft is frozen");
            _mintable = !_mintable;
        }   

        function getFrozen() public view returns (bool) {
            return _frozen;
        }

        function flipFrozen() public onlyOwner{
            _frozen = !_frozen;
        }

    }

