// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title DocumentVerify
 * @dev Decentralized document verification smart contract using blockchain and IPFS
 */
contract DocumentVerify {
    
    struct Document {
        uint256 id;
        address owner;
        string ipfsHash;
        string documentName;
        bytes32 documentHash;
        uint256 uploadTime;
        bool isRevoked;
        string documentType;
    }
    
    struct Verification {
        uint256 verificationId;
        uint256 documentId;
        address verifier;
        uint256 verificationTime;
        string verificationStatus;
    }
    
    // State variables
    uint256 public documentCounter = 0;
    uint256 public verificationCounter = 0;
    
    mapping(uint256 => Document) public documents;
    mapping(string => uint256) public ipfsHashToDocId;
    mapping(bytes32 => bool) public documentHashExists;
    mapping(uint256 => Verification[]) public documentVerifications;
    mapping(address => uint256[]) public userDocuments;
    
    // Events
    event DocumentUploaded(
        uint256 indexed documentId,
        address indexed owner,
        string ipfsHash,
        string documentName,
        uint256 timestamp
    );
    
    event DocumentVerified(
        uint256 indexed documentId,
        address indexed verifier,
        string status,
        uint256 timestamp
    );
    
    event DocumentRevoked(
        uint256 indexed documentId,
        address indexed owner,
        uint256 timestamp
    );
    
    // Modifiers
    modifier documentExists(uint256 _documentId) {
        require(_documentId > 0 && _documentId <= documentCounter, "Document does not exist");
        _;
    }
    
    modifier onlyDocumentOwner(uint256 _documentId) {
        require(documents[_documentId].owner == msg.sender, "Only owner can perform this action");
        _;
    }
    
    modifier documentNotRevoked(uint256 _documentId) {
        require(!documents[_documentId].isRevoked, "Document is revoked");
        _;
    }
    
    /**
     * @dev Upload a new document to the blockchain
     * @param _ipfsHash IPFS hash of the document
     * @param _documentName Name of the document
     * @param _documentHash SHA-256 hash of the document
     * @param _documentType Type of the document (certificate, degree, etc.)
     */
    function uploadDocument(
        string memory _ipfsHash,
        string memory _documentName,
        bytes32 _documentHash,
        string memory _documentType
    ) public returns (uint256) {
        require(bytes(_ipfsHash).length > 0, "IPFS hash cannot be empty");
        require(bytes(_documentName).length > 0, "Document name cannot be empty");
        require(_documentHash != bytes32(0), "Document hash cannot be zero");
        require(!documentHashExists[_documentHash], "Document already exists");
        require(ipfsHashToDocId[_ipfsHash] == 0, "IPFS hash already used");
        
        documentCounter++;
        uint256 docId = documentCounter;
        
        documents[docId] = Document({
            id: docId,
            owner: msg.sender,
            ipfsHash: _ipfsHash,
            documentName: _documentName,
            documentHash: _documentHash,
            uploadTime: block.timestamp,
            isRevoked: false,
            documentType: _documentType
        });
        
        documentHashExists[_documentHash] = true;
        ipfsHashToDocId[_ipfsHash] = docId;
        userDocuments[msg.sender].push(docId);
        
        emit DocumentUploaded(docId, msg.sender, _ipfsHash, _documentName, block.timestamp);
        
        return docId;
    }
    
    /**
     * @dev Verify a document's authenticity
     * @param _documentId ID of the document to verify
     */
    function verifyDocument(uint256 _documentId) 
        public 
        documentExists(_documentId) 
        documentNotRevoked(_documentId) 
        returns (bool) 
    {
        Document storage doc = documents[_documentId];
        verificationCounter++;
        
        Verification memory newVerification = Verification({
            verificationId: verificationCounter,
            documentId: _documentId,
            verifier: msg.sender,
            verificationTime: block.timestamp,
            verificationStatus: "VERIFIED"
        });
        
        documentVerifications[_documentId].push(newVerification);
        
        emit DocumentVerified(_documentId, msg.sender, "VERIFIED", block.timestamp);
        
        return true;
    }
    
    /**
     * @dev Get document details
     * @param _documentId ID of the document
     */
    function getDocumentDetails(uint256 _documentId) 
        public 
        view 
        documentExists(_documentId) 
        returns (Document memory) 
    {
        return documents[_documentId];
    }
    
    /**
     * @dev Revoke a document
     * @param _documentId ID of the document to revoke
     */
    function revokeDocument(uint256 _documentId) 
        public 
        documentExists(_documentId) 
        onlyDocumentOwner(_documentId) 
        documentNotRevoked(_documentId) 
    {
        documents[_documentId].isRevoked = true;
        emit DocumentRevoked(_documentId, msg.sender, block.timestamp);
    }
    
    /**
     * @dev Check if a document is valid and not revoked
     * @param _documentId ID of the document
     */
    function isDocumentValid(uint256 _documentId) 
        public 
        view 
        documentExists(_documentId) 
        returns (bool) 
    {
        return !documents[_documentId].isRevoked;
    }
    
    /**
     * @dev Get document verification history
     * @param _documentId ID of the document
     */
    function getVerificationHistory(uint256 _documentId) 
        public 
        view 
        documentExists(_documentId) 
        returns (Verification[] memory) 
    {
        return documentVerifications[_documentId];
    }
    
    /**
     * @dev Get all documents uploaded by a user
     * @param _user Address of the user
     */
    function getUserDocuments(address _user) 
        public 
        view 
        returns (uint256[] memory) 
    {
        return userDocuments[_user];
    }
    
    /**
     * @dev Get total number of documents
     */
    function getTotalDocuments() public view returns (uint256) {
        return documentCounter;
    }
    
    /**
     * @dev Get total number of verifications
     */
    function getTotalVerifications() public view returns (uint256) {
        return verificationCounter;
    }
    
    /**
     * @dev Verify document by hash
     * @param _documentHash SHA-256 hash of the document
     */
    function verifyDocumentByHash(bytes32 _documentHash) 
        public 
        view 
        returns (bool) 
    {
        return documentHashExists[_documentHash] && !documents[ipfsHashToDocId[bytes32(0)]].isRevoked;
    }
}
