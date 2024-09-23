// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Wallet {
    address[] public owners;
    uint public numConfarmations;

    struct Transaction {
        address to;
        uint id;
        address token;
        bool executed;
    }

    mapping(uint => mapping(address => bool)) isConfirmed;
    Transaction[] public transactions;

    event TransactionSubmitted(
        uint transactionId,
        address sender,
        address reciver,
        uint id
    );
    event TransactionConfirmed(uint transactionId, address owner);
    event TransactionExecuted(uint transactionId);
    event Received(address from, uint value);

    modifier checkTransactionId(uint _transactionId) {
        require(
            _transactionId < transactions.length,
            "This transaction does not exist"
        );
        _;
    }

    constructor(address[] memory _owners, uint _numConfirmations) {
        require(_owners.length > 1, "Contract must have more than one owner");
        require(
            _numConfirmations > 0 && _numConfirmations <= _owners.length,
            "Confarmations are not in sync with the number of owners"
        );

        for (uint i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid owner");
            owners.push(_owners[i]);
        }

        numConfarmations = _numConfirmations;
    }

    function submitTransaction(
        address _to,
        address _token,
        uint _id
    ) public payable {
        require(_to != address(0), "Invalid reciver address");
        // ToDo: Chake the existence of an NFT

        uint transactionId = transactions.length;
        transactions.push(
            Transaction({to: _to, id: _id, token: _token, executed: false})
        );

        emit TransactionSubmitted(transactionId, msg.sender, _to, _id);
    }

    function confirmTransaction(
        uint _transactionId
    ) public checkTransactionId(_transactionId) {
        // ToDo: Chake the existence of an NFT

        isConfirmed[_transactionId][msg.sender] = true;
        emit TransactionConfirmed(_transactionId, msg.sender);

        if (isTransactionConfirmed(_transactionId)) {
            executTransaction(_transactionId);
        }
    }

    function isTransactionConfirmed(
        uint _transactionId
    ) internal view checkTransactionId(_transactionId) returns (bool) {
        uint confirms;

        for (uint i = 0; i < owners.length; i++) {
            if (isConfirmed[_transactionId][owners[i]]) {
                confirms = confirms + 1;
            }
        }

        return confirms >= numConfarmations;
    }

    function executTransaction(
        uint _transactionId
    ) internal checkTransactionId(_transactionId) {
        require(
            !transactions[_transactionId].executed,
            "The transaction has already been executed"
        );
        transactions[_transactionId].executed = true;
        uint id = transactions[_transactionId].id;

        IERC721 token = IERC721(transactions[_transactionId].token);

        token.transferFrom(address(this), transactions[_transactionId].to, id);
        emit TransactionExecuted(_transactionId);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
