// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "./Wallet.sol";

contract Factory {
    /*
     *  Events
     */
    event ContractInstantiation(address sender, address wallet);

    /*
     *  Storage
     */
    mapping(address => bool) public isWallet;
    mapping(address => address[]) public wallets;
    uint public walletCount;

    /*
     * Public functions
     */
    /// @dev Returns number of wallets by creator.
    /// @param creator Contract creator.
    /// @return Returns number of wallets by creator.
    function getCountOfUsersWallets(
        address creator
    ) public view returns (uint) {
        return wallets[creator].length;
    }

    /*
     * Internal functions
     */
    /// @dev Registers contract in factory registry.
    /// @param wallet Address of contract instantiation.
    function register(address wallet) internal {
        isWallet[wallet] = true;
        wallets[msg.sender].push(wallet);
        walletCount++;
        emit ContractInstantiation(msg.sender, wallet);
    }
}
