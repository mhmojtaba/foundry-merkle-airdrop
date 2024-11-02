// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {MyToken} from "src/MyToken.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERc20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 public constant S_ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public constant S_AMOUNT_TO_MINT = 100 * 1e18;

    function run() public returns (MerkleAirdrop, MyToken) {
        vm.startBroadcast();
        MyToken token = new MyToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(IERC20(address(token)), S_ROOT);
        token.mint(token.owner(), S_AMOUNT_TO_MINT);
        token.transfer(address(airdrop), S_AMOUNT_TO_MINT);

        vm.stopBroadcast();
        return (airdrop, token);
    }
}
