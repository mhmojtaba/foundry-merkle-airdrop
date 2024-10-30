// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/// @title Merkle Airdrop
/// @author Mojtaba.web3
/// @notice  Airdrop tokens to users who can prove they are in a merkle proof
/// @dev a merkle proofs allow us to prove that some piece of data that we want is in fact in a group of data
contract MerkleAirdrop {
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    address[] claimers;
    IERC20 private immutable i_airdropToken;
    bytes32 private immutable i_merkleRoot;

    
    constructor(IERC20 _airdropToken, bytes32 _merkleRoot) {
        i_airdropToken = _airdropToken;
        i_merkleRoot = _merkleRoot;
    }

    /// @notice calculate using the account and the amount, the hashe proof -> leaf hash
    /// @dev the merkle root is the hash of the merkle tree
    /// @param account the account that will receive the tokens
    /// @param amount the amount of tokens to be claimed
    /// @param proof the intermediate hashes that are required in order to be able to calculate the root to compare with expected root

    function claim(address account, uint256 amount , bytes32[] calldata proof) external view{
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account,amount)))); // hashes twice to avoid collisions
        if(!MerkleProof.verify(proof, i_merkleRoot, leaf)){
            revert MerkleAirdrop__InvalidProof();
        }
    }
}