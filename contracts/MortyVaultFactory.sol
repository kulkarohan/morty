// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// ============ Imports ============

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/Pausable.sol';

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol';

import './InitializedProxy.sol';
import './MortyVault.sol';

contract MortyVaultFactory is Ownable, Pausable {
    /// @notice the number of ERC721 vaults
    uint256 public vaultCount;

    /// @notice the mapping of vault number to vault contract
    mapping(uint256 => address) public vaults;

    /// @notice the MortyVault logic contract
    address public immutable logic;

    event Mint(address indexed token, uint256 id, address vault, uint256 vaultId);

    constructor() {
        logic = address(new MortyVault());
    }

    function mint(
        string memory _name,
        string memory _symbol,
        address _token,
        uint256 _id
    ) external whenNotPaused returns (uint256) {
        bytes memory _initializationCalldata = abi.encodeWithSignature(
            'initialize(address,address,uint256,string,string)',
            msg.sender,
            _token,
            _id,
            _name,
            _symbol
        );

        address vault = address(new InitializedProxy(logic, _initializationCalldata));

        emit Mint(_token, _id, vault, vaultCount);

        IERC721(_token).safeTransferFrom(msg.sender, vault, _id);

        vaults[vaultCount] = vault;
        vaultCount++;

        return vaultCount - 1;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
