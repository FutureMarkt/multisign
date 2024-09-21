// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Wallet {
    address[] public owners;
    uint public numConfarmations;

    struct Transaction {
        address to;
        uint value;
        address token;
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

    function submitTransaction(address _to, address _token) public payable {
        require(_to != address(0), "Invalid reciver address");
        require(msg.value > 0, "The amount of ETH must be more than zero");

        uint transactionId = transactions.length;
        transactions.push(
            Transaction({
                to: _to,
                value: msg.value,
                token: _token,
                executed: false
            })
        );

        emit TransactionSubmitted(transactionId, msg.sender, _to, msg.value);
    }

    function confirmTransaction(
        uint _transactionId
    ) public checkTransactionId(_transactionId) {
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
        uint value = transactions[_transactionId].value;

        IERC20 token = IERC20(transactions[_transactionId].token);
        uint256 contractBalance = token.balanceOf(address(this));
        require(contractBalance >= value, "Not enough tokens on the contract");

        require(
            token.transfer(transactions[_transactionId].to, value),
            "Token transfer failed"
        );
        emit TransactionExecuted(_transactionId);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
