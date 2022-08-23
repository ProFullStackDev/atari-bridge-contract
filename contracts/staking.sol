// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking is Ownable {
    struct StakeInfo {
        uint amount;
        uint latestUpdate;
    }

    mapping(address => StakeInfo) public stakedInfo;
    uint public totalStakedAmount;
    uint public totalLockedAmount;
    uint public latestUpdate;

    //stake info
    address public tokenAddress;
    uint public rewardRate;
    uint public lockedPeriod;

    function setTokenAddress(address _tokenAddress) external onlyOwner {
        tokenAddress = _tokenAddress;
    }

    function setStakeTerms(uint _rewardRate, uint _lockedPeriod)
        external
        onlyOwner
    {
        rewardRate = _rewardRate;
        lockedPeriod = _lockedPeriod;
    }

    function withdraw(address to, uint amount) external onlyOwner {
        (bool success, ) = to.call{value: amount}("");
        require(success, "transfer failed");
    }

    function withdrawToken(address to, uint amount) external onlyOwner {
        IERC20(tokenAddress).transfer(to, amount);
    }

    function stake(uint amount) external {
        updateRewardforUser();
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        stakedInfo[msg.sender].amount += amount;
        stakedInfo[msg.sender].latestUpdate = block.timestamp;
        totalStakedAmount += amount;
        totalLockedAmount += amount;
        latestUpdate = block.timestamp;
    }

    function unStake(uint amount) external {
        require(
            lockedPeriod <
                (block.timestamp - stakedInfo[msg.sender].latestUpdate),
            "locked"
        );
        updateRewardforUser();
        require(stakedInfo[msg.sender].amount <= amount, "invalid amount");
        IERC20(tokenAddress).transfer(msg.sender, amount);
        stakedInfo[msg.sender].amount -= amount;
    }

    function updateReward() public {
        totalLockedAmount +=
            (totalStakedAmount *
                (block.timestamp - latestUpdate) *
                rewardRate) /
            10**6;
    }

    function updateRewardforUser() public {
        updateReward();
        uint reward = (stakedInfo[msg.sender].amount *
            (block.timestamp - stakedInfo[msg.sender].latestUpdate) *
            rewardRate) / 10**6;
        stakedInfo[msg.sender].amount += reward;
        totalStakedAmount += reward;
        stakedInfo[msg.sender].latestUpdate = block.timestamp;
    }

    function getLockedAmount(address user) external view returns (uint amount) {
        uint reward = (stakedInfo[user].amount *
            (block.timestamp - stakedInfo[user].latestUpdate) *
            rewardRate) / 10**6;
        return reward + stakedInfo[user].amount;
    }

    receive() external payable {}

    fallback() external {}
}
