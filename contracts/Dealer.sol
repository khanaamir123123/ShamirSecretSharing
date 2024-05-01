// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";

import "./ShamirSecretSharing.sol";

contract Dealer is Ownable {
    
    ShamirSecretSharing private sss;

    uint256 public threshold;
    uint256 public numShares;
    uint256 public secret;

    mapping(address => uint256[]) public shares;

    event SecretShared(address indexed party, uint256[] shares);

    constructor(uint256 _threshold, uint256 _numShares, address _sssAddress, address _initialOwner) Ownable(_initialOwner) {
        threshold = _threshold;
        numShares = _numShares;
        sss = ShamirSecretSharing(_sssAddress);
    }

    function setSecret(uint256  _secret) external  onlyOwner {
        secret = _secret;
    }

    function shareSecret(address[] memory parties, address tokenAddress) external onlyOwner {
        require(parties.length == numShares, "Invalid number of parties");

        uint256[] memory secretShares = sss.generateShares(secret, threshold, numShares);

        for (uint256 i = 0 ; i < parties.length; i++) {
            shares[parties[i]] = secretShares;
            IERC721(tokenAddress).safeTransferFrom(address(this), parties[i], secretShares[i]);
            emit SecretShared(parties[i], secretShares);
        }
    }
}
