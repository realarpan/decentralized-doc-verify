// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title BatchDocumentProcessor
 * @dev Handles batch document uploads and verification
 */
contract BatchDocumentProcessor {
    
    struct BatchJob {
        uint256 batchId;
        address submitter;
        uint256 documentCount;
        uint256[] documentIds;
        bool isProcessed;
        uint256 createdAt;
    }
    
    mapping(uint256 => BatchJob) public batchJobs;
    uint256 public batchCounter = 0;
    
    event BatchCreated(uint256 indexed batchId, address indexed submitter, uint256 documentCount);
    event BatchProcessed(uint256 indexed batchId, uint256 timestamp);
    
    function createBatch(uint256[] memory _documentIds) public returns (uint256) {
        require(_documentIds.length > 0, "Empty batch");
        require(_documentIds.length <= 100, "Batch too large");
        
        batchCounter++;
        BatchJob storage batch = batchJobs[batchCounter];
        batch.batchId = batchCounter;
        batch.submitter = msg.sender;
        batch.documentCount = _documentIds.length;
        batch.documentIds = _documentIds;
        batch.createdAt = block.timestamp;
        
        emit BatchCreated(batchCounter, msg.sender, _documentIds.length);
        return batchCounter;
    }
    
    function processBatch(uint256 _batchId) public {
        BatchJob storage batch = batchJobs[_batchId];
        require(!batch.isProcessed, "Already processed");
        batch.isProcessed = true;
        emit BatchProcessed(_batchId, block.timestamp);
    }
    
    function getBatch(uint256 _batchId) public view returns (BatchJob memory) {
        return batchJobs[_batchId];
    }
}
