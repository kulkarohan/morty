// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/// ============ Imports ============

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';

contract MortyVault is ERC20Upgradeable, ERC721HolderUpgradeable {
    /// ============ Collateral Token Information ============

    /// @notice the ERC721 token address of the vault's token
    address public token;
    /// @notice the ERC721 token ID of the vault's token
    uint256 public id;

    /// ============ Vault Information ============

    /// @notice the address who initially deposited the NFT
    address public curator;
    /// @notice the amount of mortys in the vault
    uint256 public balance;
    /// @notice a boolean to indicate if the vault has closed
    bool public vaultClosed;
    ///
    string name;
    ///
    string symbol;
    ///
    address public buyerLP;

    /// ============ Events ============

    event CollateralSwapped(
        address curator,
        address tokenAddress,
        uint256 previousTokenId,
        uint256 newTokenId
    );

    event MartingaleStarted(address curator, address token, string name, string symbol);

    /// ============ Vault Initializer ============

    function initialize(
        address _curator,
        address _token,
        uint256 _id,
        string memory _name,
        string memory _symbol
    ) external initializer {
        // initialize inherited contracts
        __ERC20_init(_name, _symbol);
        __ERC721Holder_init();

        // set storage variables
        token = _token;
        id = _id;
        curator = _curator;
        name = _name;
        symbol = _symbol;

        // initialize vault with a balance of 100 tokens
        _mint(address(this), 100000000000000000000);

        balance = 100000000000000000000;
    }

    /// ============ Curator Functions ============

    function start() external {
        require(msg.sender == curator);
        require(balanceOf(address(this)) == 100000000000000000000);

        // approve transfer of 50 tokens
        this.approve(msg.sender, 50000000000000000000);
        // transfer 50 tokens to curator
        transferFrom(address(this), curator, 50000000000000000000);

        balance = 50000000000000000000;

        // trigger Martingale RNG
    }

    function swapCollateral(uint256 _tokenId) external {
        require(msg.sender == curator, 'Only curator can replace collateral');
        require(msg.sender == IERC721(token).ownerOf(_tokenId));

        // Transfer token to vault
        IERC721(token).safeTransferFrom(msg.sender, address(this), _tokenId);
        // Send previous token back to user
        IERC721(token).safeTransferFrom(address(this), msg.sender, id);

        emit CollateralSwapped(msg.sender, token, id, _tokenId);

        // Update token id
        id = _tokenId;
    }
}
