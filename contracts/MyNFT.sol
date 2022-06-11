    //"SPDX-License-Identifier: UNLICENSED"
    pragma solidity ^0.8.0;

    import "@openzeppelin/contracts/token/ERC721/ERC721.sol";//implementation of the ERC721 standard
    import "@openzeppelin/contracts/utils/Counters.sol";//provides counters that can only be incremented or decremented by one
    import "@openzeppelin/contracts/access/Ownable.sol";//set up access control
    import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
    import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
    import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";


    // define and save the property of each nft
    contract NFTProperty is Ownable {
        address private NFTOwner; // the owner of the nft
        uint256 private class_id; // the id of the class
        bool private transferable = true; // if true nft can be transferred otherwise no
        bool private mintable = true; // if true nft can be mintted otherwise no
        bool private burnable = true; // if true nft can be burned otherwise no
        bool private frozen = false; // if true the property below can be changed otherwise no

        function setClassId(uint256 _classId) public onlyOwner{
            class_id = _classId;
        }


        function setNFTOwner(address _nftOwner) public {
            NFTOwner = _nftOwner;
        }

        function getNFTOwner() public view returns (address){
            return NFTOwner;
        }


        function getTransferable() public view returns (bool) {
            return transferable;
        }

        function flipTransferable() public onlyOwner {
            require(frozen == false, "the nft is frozen");
            transferable = !transferable;
        }
        

        function getBurnable() public view returns (bool) {
            return burnable;
        }

        function flipBurnable() public onlyOwner {
            require(frozen == false, "the nft is frozen");
            burnable = !burnable;
        }

        function getMintable() public view returns (bool) {
            return mintable;
        }

        function flipMintable() public onlyOwner {
            require(frozen == false, "the nft is frozen");
            mintable = !mintable;
        }   

        function getFrozen() public view returns (bool) {
            return frozen;
        }

        function flipFrozen() public onlyOwner{
            frozen = !frozen;
        }


    }





    contract MyNFT is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable {
        using Counters for Counters.Counter;
        NFTProperty private nftProperty = new NFTProperty();
        uint256 private class_id; // the id of the nft class
        Counters.Counter private _tokenIds; // start from 1 increment every time when nft mint

        //具有转账功能的智能合约的 constructor 必须显式的指定为 payable。
        //initialize the name of the nft and the owner of the nft
        constructor() ERC721("MyNFT", "NFT") payable {
            nftProperty.setNFTOwner(msg.sender);
        }

        //mintNFT calls some methods from the inherited ERC-721 library, and ultimately returns a number that represents the ID of the freshly minted NFT
        function mintNFT()
            public 
            returns (uint256)
        {
            require(nftProperty.getMintable() == true, "the NFT is not mintable");
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            _safeMint(msg.sender, newItemId);
            return newItemId;
        }

        // set the id of the class
        function setClassId(uint256 _classId) public {
            class_id = _classId;
            nftProperty.setClassId(_classId);
        }

        // if the caller is approved or owner, it can set the specific nft with URI (metadata)
        function setTokenURI(uint256 _tokenId, string memory _tokenURI) public {
        require(
            _isApprovedOrOwner(_msgSender(), _tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
            _setTokenURI(_tokenId, _tokenURI);
        }   

        //token with pausable token transfers, minting and burning, to see Useful for scenarios such as preventing trades until the end of an evaluation period
        function _beforeTokenTransfer(address _from, address _to, uint256 _tokenId)
            internal
            override(ERC721, ERC721Enumerable)
        {
            super._beforeTokenTransfer(_from, _to, _tokenId);
        }

        //transfer the ownership of the nft
        function transferOwnership(address _newOwner) public onlyOwner override (Ownable){
            require(msg.sender == nftProperty.getNFTOwner(), "the caller have no right to transfer ownership"); 
            nftProperty.transferOwnership(_newOwner);
            nftProperty.setNFTOwner(_newOwner);
        }

        //burn the nft (sending it into address 0)
        function _burn(uint256 _tokenId) internal override(ERC721, ERC721URIStorage) {
            require(nftProperty.getBurnable() == true, "The nft is not burnable");
            super._burn(_tokenId);
        }

        // get the tokenURI of the specific tokenid
        function tokenURI(uint256 _tokenId)
            public
            view
            override(ERC721, ERC721URIStorage)
            returns (string memory)
        {
            return super.tokenURI(_tokenId);
        }

        // a standardized way to retrieve royalty payment
        function supportsInterface(bytes4 _interfaceId)
            public
            view
            override(ERC721, ERC721Enumerable)
            returns (bool)
        {
            return super.supportsInterface(_interfaceId);
        }


        // transfer nft from one to other
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
            require(nftProperty.getTransferable() == true, "The nft is not burnable");


            _transfer(from, to, tokenId);
        }

        // similiar to transferFrom(), but Safetransferfrom() function is just used to check if the address receiving the token is erc721 receiver or not
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
            require(
                nftProperty.getTransferable() == true, 
                "The nft is not burnable"
                );

            _safeTransfer(from, to, tokenId, _data);
        }

        // if the condition is satisfied, the function will run, otherwise it will throw exception (modifier)
        modifier isTransferable() {
            require(
                nftProperty.getTransferable() == true, 
                "Memberships: not transferable"
            );
            _;
        }


        //functions to get and set the properties of the nft
        function getTransferable() public view returns (bool) {
            return nftProperty.getTransferable();
        }

        function flipTransferable() public  {
            require(nftProperty.getFrozen() == false, "the nft is frozen");
            nftProperty.flipTransferable();
        }
        

        function getBurnable() public view returns (bool) {
            return nftProperty.getBurnable();
        }

        function flipBurnable() public {
            require(nftProperty.getFrozen() == false, "the nft is frozen");
            nftProperty.flipBurnable();
        }

        function getMintable() public view returns (bool) {
            return nftProperty.getMintable();
        }

        function flipMintable() public {
            require(nftProperty.getFrozen() == false, "the nft is frozen");
            nftProperty.flipMintable();
        }   

        function getFrozen() public view returns (bool) {
            return nftProperty.getFrozen();
        }

        function flipFrozen() public{
            nftProperty.flipFrozen();
        }

    }


    