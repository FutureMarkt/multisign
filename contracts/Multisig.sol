// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

contract Multisig {
    address[] public owners;
    uint public confarmations;

    struct Transaction {
        address to;
        uint value;
        bool executed;
    }

    mapping(uint => mapping(address => bool)) isConfirmed;
    Transaction[] public transactions;

    event TransactionSubmitted(
        uint transactionId,
        address sender,
        address reciver,
        uint amount
    );

    constructor(address[] memory _owners, uint _confarmations) {
        require(_owners.length > 1, "Contract must have more than one owner");
        require(
            _confarmations > 0 && _confarmations <= _owners.length,
            "Confarmations are not in sync with the number of owners"
        );

        for (uint i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid owner");
            owners.push(_owners[i]);
        }

        confarmations = _confarmations;
    }

    function submitTransaction(address _to) public payable {
        require(_to != address(0), "Invalid reciver address");
        require(msg.value > 0, "The amount of ETH must be more than zero");

        uint transactionId = transactions.length;
        transactions.push(
            Transaction({to: _to, value: msg.value, executed: false})
        );

        emit TransactionSubmitted(transactionId, msg.sender, _to, msg.value);
    }
}
