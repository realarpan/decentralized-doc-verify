// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
contract WebhookManager {
    mapping(uint256 => string[]) public webhooks;
    event WebhookCreated(uint256 indexed documentId, string webhookUrl);
    function addWebhook(uint256 _documentId, string memory _url) public {
        webhooks[_documentId].push(_url);
        emit WebhookCreated(_documentId, _url);
    }
    function getWebhooks(uint256 _documentId) public view returns (string[] memory) {
        return webhooks[_documentId];
    }
}
