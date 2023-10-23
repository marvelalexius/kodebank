// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KodeBank is Ownable {
    address internal tokenAddress;

    struct depositData {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => depositData) internal userToDepositData;

    uint256 public totalUsers = 0;

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }

    function hasDepositData(address _address) public view returns (depositData) {
        return userToDepositData[_address];
    }

    function totalDeposited() public view returns (uint256) {
        return userToDepositData[msg.sender].amount;
    }

    function withdraw() public {
        require(
            block.timestamp >=
                (userToDepositData[msg.sender].timestamp + 10 seconds),
            "You still in the lock-up period"
        );

        userToDepositData[msg.sender].amount = 0;
        userToDepositData[msg.sender].timestamp = block.timestamp;

        totalUsers--;

        IERC20(tokenAddress).transfer(
            msg.sender,
            userToDepositData[msg.sender].amount
        );
    }

    function deposit(uint256 _amount) public {
        userToDepositData[msg.sender].timestamp = block.timestamp;
        if (userToDepositData[msg.sender]) {
            userToDepositData[msg.sender].amount += _amount;
        } else {
            userToDepositData[msg.sender].amount = _amount;
            totalUsers++;
        }

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);
    }
}