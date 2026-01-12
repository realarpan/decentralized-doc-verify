// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
contract DocumentExpiration {
    mapping(uint256 => uint256) public expirationDates;
    event DocumentExpired(uint256 indexed documentId);
    function setExpiration(uint256 _documentId, uint256 _expirationTime) public {
        expirationDates[_documentId] = _expirationTime;
    }
    function isExpired(uint256 _documentId) public view returns (bool) {
        return expirationDates[_documentId] < block.timestamp;
    }
}
