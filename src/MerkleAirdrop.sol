// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERc20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/// @title Merkle Airdrop
/// @author Mojtaba.web3
/// @notice  Airdrop tokens to users who can prove they are in a merkle proof
/// @dev a merkle proofs allow us to prove that some piece of data that we want is in fact in a group of data
contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    event claimed(address indexed account, uint256 amount);

    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    address[] claimers;
    IERC20 private immutable i_airdropToken;
    bytes32 private immutable i_merkleRoot;
    mapping(address claimer => bool claimed) private s_hasClaimed;

    constructor(IERC20 _airdropToken, bytes32 _merkleRoot) EIP712("MerkleAirdrop", "1") {
        i_airdropToken = _airdropToken;
        i_merkleRoot = _merkleRoot;
    }

    /// @notice calculate using the account and the amount, the hashe proof -> leaf hash
    /// @dev the merkle root is the hash of the merkle tree
    /// @param account the account that will receive the tokens
    /// @param amount the amount of tokens to be claimed
    /// @param proof the intermediate hashes that are required in order to be able to calculate the root to compare with expected root

    function claim(address account, uint256 amount, bytes32[] calldata proof, uint8 v, bytes32 r, bytes32 s) external {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        
        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount)))); // hashes twice to avoid collisions
        if (!MerkleProof.verify(proof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        s_hasClaimed[account] = true;
        claimers.push(account);
        emit claimed(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    function _isValidSignature(address account, bytes32 digestMessage, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        (address signer, ,)=ECDSA.tryRecover(digestMessage, v, r, s);
        return signer == account;
    }

    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return
            _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))));
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function hasClaimed(address account) external view returns (bool) {
        return s_hasClaimed[account];
    }

    function getClaimers() external view returns (address[] memory) {
        return claimers;
    }

    function getAirdropToken() public view returns (IERC20) {
        return i_airdropToken;
    }
}
