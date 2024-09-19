// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "./Factory.sol";
import "./Wallet.sol";

/// @title Multisignature wallet factory - Allows creation of multisig wallet.
/// @author Stefan George - <stefan.george@consensys.net>
contract WalletFactory is Factory {
    /*
     * Public functions
     */
    /// @dev Allows verified creation of multisignature wallet.
    /// @param _owners List of initial owners.
    /// @param _required Number of required confirmations.
    /// @return walletAddres Returns wallet address.
    function create(
        address[] memory _owners,
        uint _required
    ) public returns (address walletAddres) {
        Wallet wallet = new Wallet(_owners, _required);
        walletAddres = address(wallet);
        register(walletAddres);
    }
}
