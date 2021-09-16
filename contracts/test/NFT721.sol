// SPDX-License-Identifier: MIT
// FOR TEST PURPOSES ONLY
pragma solidity 0.8.7;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

contract NFT is ERC721 {
    constructor() ERC721('Wizard Hat Ocelot', 'OCELOT') {}

    function mint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }
}
