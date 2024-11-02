// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {MyToken} from "src/MyToken.sol";
import {DeployMerkleAirdrop} from "script/DeployMerkleAirdrop.s.sol";

// Interact with airdrop contract
contract ClaimAirdrop is Script {
    error claimAirdropScripT__signature_must_be_65_bytes();


    address claiming_address = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 claiming_amount = 25 * 1e18;
    bytes32[] proof = [
        0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad,
            0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576
        
    ];

    bytes private SIGNATURE = hex"fbd2270e6f23fb5fe9248480c0f4be8a4e9bd77c3ad0b1333cc60b5debc511602a2a06c24085d8d7c038bad84edc53664c8ce0346caeaa3570afec0e61144dc11c";
    function claimAirdrop(address airdrop) {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = spliteSignature(SIGNATURE);
        MerkleAirdrop(airdrop).claim(claiming_address, claiming_amount, proof,v,r,s);
        vm.stopBroadcast();
    }

    function spliteSignature(bytes memory signature) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if(signature.length != 65) revert claimAirdropScripT__signature_must_be_65_bytes();

        bytes memory r = signature[0..32]; // the first 32 bytes
        bytes memory s = signature[32..64]; // the second 32 bytes
        bytes memory v = signature[64..65]; // the last byte

        return (uint8(v[0]), bytes32(r), bytes32(s));
        
    }

    function run() public  {
        address mostRecentlyDeployer = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployer);
        console.log("MerkleAirdrop: %s", address(mostRecentlyDeployer));
    }
}



/*
after deployment using anvil -> 
* use -> cast call merkleAirdropsmartcontractaddress "getMessageHash(address,uint256)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 25000000000000000000 --rpc-url http://localhost:8545  ====> you'll get a hashed message
* then -> cast wallet sign --no-hash hashedmessag --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 you'll get the signature

deploy again
* deployment usign another private key -> forge script script/Interact.s.ol:ClaimAirdrop --rpc-url http://127.0.0.1:8545 --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
*/