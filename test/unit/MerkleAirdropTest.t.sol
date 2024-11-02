// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {MyToken} from "src/MyToken.sol";
import {DeployMerkleAirdrop} from "script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop airdrop;
    MyToken token;
    DeployMerkleAirdrop deployer;
    address sender;

    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    bytes32[] public PROOF = [
        bytes32(0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a),
        bytes32(0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576)
    ];

    address gasPayer;
    address user;
    uint256 userPrivateKey;

    function setUp() public {
        deployer = new DeployMerkleAirdrop();
        (airdrop, token) = deployer.run();
        (user, userPrivateKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");

        console.log("MerkleAirdropTest_setup__Deployed MerkleAirdrop to %s", address(airdrop));
        console.log("MerkleAirdropTest_setup__Deployed MyToken to %s", address(token));
    }

    function testUserCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digestMessage = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);

        // sign message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digestMessage); 

        // gaspayer can call claim 
        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        uint256 endingBalance = token.balanceOf(user);
        console.log("MerkleAirdropTest_testUserCanClaim__ending balance: %s", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
