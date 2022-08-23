// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Treasury is Ownable {
    event Deposited(address from, uint toChain, uint amount);

    address public tokenAddress;

    function setTokenAddress(address _tokenAddress) external onlyOwner {
        tokenAddress = _tokenAddress;
    }

    function multiSend(address[] memory tos, uint[] memory amounts)
        external
        onlyOwner
    {
        require(tos.length == amounts.length, "Invalid request");
        for (uint i = 0; i < tos.length; i++) {
            (bool success, ) = tos[i].call{value: amounts[i]}("");
            require(success, "transfer failed");
        }
    }

    function multiSendToken(address[] memory tos, uint[] memory amounts)
        external
        onlyOwner
    {
        require(tos.length == amounts.length, "Invalid request");
        for (uint i = 0; i < tos.length; i++) {
            IERC20(tokenAddress).transfer(tos[i], amounts[i]);
        }
    }

    function deposit(uint amount, uint toChain) external {
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        emit Deposited(msg.sender, toChain, amount);
    }

    receive() external payable {}
    fallback() external {}
}
