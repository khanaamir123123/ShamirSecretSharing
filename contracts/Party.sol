// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ShamirSecretSharing.sol";

contract Party is Ownable {
    ShamirSecretSharing private sss;
    uint256 public threshold;
    address public dealerAddress;

    uint256[] public shares;

    event SecretReconstructed(uint256 secret);

    constructor(address _sssAddress, uint256 _threshold, address _dealerAddress, address _initialOwner) Ownable(_initialOwner) {
        sss = ShamirSecretSharing(_sssAddress);
        threshold = _threshold;
        dealerAddress = _dealerAddress;
    }

    function reconstructSecret() external onlyOwner {
        require(shares.length >= threshold, "Threshold not reached");

        uint256[] memory indices = new uint256[](threshold);
        uint256[] memory sharesToReconstruct = new uint256[](threshold);

        for (uint256 i = 0; i < threshold; i++) {
            indices[i] = i;
            sharesToReconstruct[i] = shares[i];
        }

        uint256 secret = sss.reconstructSecret(sharesToReconstruct, indices);
        emit SecretReconstructed(secret);
    }
}
