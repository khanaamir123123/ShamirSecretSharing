
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ShamirSecretSharing {
    uint256 constant public prime = 115792089237316195423570985008687907853269984665640564039457584007913129639747; // 2^256 - 189
    
    function generateShares(uint256 secret, uint256 threshold, uint256 numShares) public pure returns (uint256[] memory) {
        require(threshold > 0 && threshold <= numShares, "Invalid threshold or number of shares");
        
        uint256[] memory shares = new uint256[](numShares);
        uint256[] memory coefficients = new uint256[](threshold);
        
        coefficients[0] = secret; // Set the constant term as the secret
        
        // Generate random coefficients for the remaining terms
        for (uint256 i = 1; i < threshold; i++) {
            coefficients[i] = uint256(keccak256(abi.encodePacked(secret, i)));
        }
        
        // Calculate shares using the polynomial defined by the coefficients
        for (uint256 j = 0; j < numShares; j++) {
            uint256 x = j + 1; // Share indices start from 1
            
            shares[j] = evaluatePolynomial(coefficients, x);
        }
        
        return shares;
    }
    
    function evaluatePolynomial(uint256[] memory coefficients, uint256 x) internal pure  returns (uint256) {
        require(coefficients.length > 0, "No coefficients provided");
        
        uint256 result = 0;
        uint256 powerOfX = 1;
        
        for (uint256 i = 0; i < coefficients.length; i++) {
            result = (result + (coefficients[i] * powerOfX) % prime) % prime;
            powerOfX = (powerOfX * x) % prime;
        }
        
        return result;
    }
    
    function reconstructSecret(uint256[] memory shares, uint256[] memory indices) public pure returns (uint256) {
        require(shares.length == indices.length && shares.length > 0, "Invalid input");
        
        uint256 secret = 0;
        
        for (uint256 i = 0; i < shares.length; i++) {
            uint256 numerator = shares[i];
            uint256 denominator = 1;
            
            for (uint256 j = 0; j < shares.length; j++) {
                if (i == j) continue;
                numerator = (numerator * (prime - indices[j])) % prime;
                denominator = (denominator * (indices[i] - indices[j])) % prime;
            }
            
            uint256 lagrangeCoefficient = (modInverse(denominator) * numerator) % prime; // Adjusted here
            secret = (secret + lagrangeCoefficient) % prime;
        }
        
        return secret;
    }
    
    function modInverse(uint256 a) internal pure returns (uint256) {
        uint256 m = prime;
        if (a == 0 || a == 1) return a;
        int256 m0 = int256(m);
        int256 a0 = int256(a);
        int256 y = 0;
        int256 x = 1;
        while (a0 > 1) {
            int256 q = a0 / m0;
            int256 t = m0;
            m0 = a0 % m0;
            a0 = t;
            t = y;
            y = x - q * y;
            x = t;
        }
        if (x < 0) x += int256(m); // Cast x to int256
        return uint256(x);
    }
}









