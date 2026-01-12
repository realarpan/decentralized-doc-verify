// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
contract RateLimiter {
    mapping(address => uint256) public requestCounts;
    mapping(address => uint256) public lastResetTime;
    uint256 public maxRequests = 100;
    event RateLimitExceeded(address indexed user);
    function checkLimit(address _user) public {
        if (block.timestamp > lastResetTime[_user] + 1 hours) {
            requestCounts[_user] = 0;
            lastResetTime[_user] = block.timestamp;
        }
        require(requestCounts[_user] < maxRequests, "Rate limit exceeded");
        requestCounts[_user]++;
    }
}
