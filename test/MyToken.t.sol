// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Test,console2} from "forge-std/Test.sol";
import {DeployMyToken} from "../script/DeployMyToken.s.sol";
import {MyToken} from "../src/MyToken.sol";

interface MintableToken {
    function mint(address, uint256) external;
}


contract MyTokenTest is Test {
    MyToken public myToken;
    DeployMyToken public deployer; 
    uint256 BOB_STARTING_AMOUNT = 100 ether;
    //bob 和 alice：两个地址，分别代表 Bob 和 Alice，用于模拟两位用户的交易。
    address bob;
    address alice; 
    function setUp() public{
        deployer = new DeployMyToken();
        myToken = deployer.run();

        bob = makeAddr("bob");
        alice = makeAddr("alice");

        vm.prank(msg.sender);
        //给bob 转 BOB_STARTING_AMOUNT 币
        myToken.transfer(bob, BOB_STARTING_AMOUNT);
        console2.log("alice blance=>", myToken.balanceOf(alice));
        console2.log("bob blance=>", myToken.balanceOf(bob));
    }
     //测试合约的总供应量。
    function testInitialSupply() public view {
        assertEq(myToken.totalSupply(),deployer.INITIAL_SUPPLY());
    } 
    //测试用户是否能铸造代币。
    function testUsersCantMint() public {
        //预期接下来的调用会失败并回退（revert）
        vm.expectRevert(); 
        //尝试调用 myToken 合约的 mint 函数，将 1 个代币铸造到合约地址 address(this)。但是，因为 MyToken 合约没有实现 mint 函数（或者限制了铸造权限），这应该会失败并回退。
        MintableToken(address(myToken)).mint(address(this), 1);

        // MintableToken 是一个接口，声明了 mint(address,uint256) 函数。
        // 但是，你的 MyToken 合约里 并没有实现 mint 函数（你之前的 ERC20 合约只支持 transfer、approve、transferFrom 等）。
        // 当你强行把 myToken 转成 MintableToken 并调用 mint(...) 时，EVM 在合约里找不到对应的函数签名 → 直接触发 fallback，因为没有 fallback 实现 → 自动 revert。
    }
    //测试代币的授权和转账功能
    function testAllowances() public {
        uint256 initialAllowance = 1000;
        // Bob approves Alice to spend tokens on his behalf
        //模拟 bob 地址发起接下来的操作。
        vm.prank(bob);
        //Bob 允许 Alice 代表自己使用最多 1000 个代币
        myToken.approve(alice,initialAllowance);

        uint256 transferAmount = 500;
        //模拟 Alice 地址发起接下来的操作。
        vm.prank(alice);
        //Alice 使用 approve 授权的代币，将 500 个代币从 Bob 转账给自己。
        myToken.transferFrom(bob,alice,transferAmount);
        //验证 Alice 的余额是否等于 500
        assertEq(myToken.balanceOf(alice), transferAmount);
        //验证 Bob 的余额是否减少了 500，且正确更新。
        assertEq(myToken.balanceOf(bob), BOB_STARTING_AMOUNT - transferAmount);
    }
}