// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title MultiSignatureVerification
 * @dev Multi-signature wallet for document verification approvals
 */
contract MultiSignatureVerification {
    
    uint256 public requiredSignatures;
    address[] public signers;
    mapping(address => bool) public isSigner;
    
    struct VerificationRequest {
        uint256 requestId;
        uint256 documentId;
        uint256 createdAt;
        uint256 approvalsCount;
        bool isApproved;
        mapping(address => bool) approvals;
    }
    
    mapping(uint256 => VerificationRequest) public requests;
    uint256 public requestCounter = 0;
    
    event SignerAdded(address indexed signer);
    event SignerRemoved(address indexed signer);
    event VerificationRequested(uint256 indexed requestId, uint256 indexed documentId);
    event VerificationApproved(uint256 indexed requestId, address indexed signer);
    event VerificationCompleted(uint256 indexed requestId, uint256 indexed documentId);
    
    constructor(address[] memory _signers, uint256 _requiredSignatures) {
        require(_signers.length >= _requiredSignatures, "Invalid configuration");
        signers = _signers;
        requiredSignatures = _requiredSignatures;
        for (uint256 i = 0; i < _signers.length; i++) {
            isSigner[_signers[i]] = true;
        }
    }
    
    modifier onlySigner() {
        require(isSigner[msg.sender], "Not authorized");
        _;
    }
    
    function createVerificationRequest(uint256 _documentId) public returns (uint256) {
        requestCounter++;
        VerificationRequest storage request = requests[requestCounter];
        request.requestId = requestCounter;
        request.documentId = _documentId;
        request.createdAt = block.timestamp;
        emit VerificationRequested(requestCounter, _documentId);
        return requestCounter;
    }
    
    function approveVerification(uint256 _requestId) public onlySigner {
        VerificationRequest storage request = requests[_requestId];
        require(!request.approvals[msg.sender], "Already approved");
        
        request.approvals[msg.sender] = true;
        request.approvalsCount++;
        emit VerificationApproved(_requestId, msg.sender);
        
        if (request.approvalsCount >= requiredSignatures) {
            request.isApproved = true;
            emit VerificationCompleted(_requestId, request.documentId);
        }
    }
    
    function getVerificationStatus(uint256 _requestId) public view returns (bool) {
        return requests[_requestId].isApproved;
    }
    
    function getApprovalCount(uint256 _requestId) public view returns (uint256) {
        return requests[_requestId].approvalsCount;
    }
    
    function addSigner(address _signer) public {
        require(!isSigner[_signer], "Already a signer");
        isSigner[_signer] = true;
        signers.push(_signer);
        emit SignerAdded(_signer);
    }
    
    function removeSigner(address _signer) public {
        require(isSigner[_signer], "Not a signer");
        isSigner[_signer] = false;
        emit SignerRemoved(_signer);
    }
}
