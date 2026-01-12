// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title AccessControl
 * @dev Advanced role-based access control (RBAC) for document verification
 */
contract AccessControl {
    
    // Role definitions
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");
    bytes32 public constant DOCUMENT_MANAGER_ROLE = keccak256("DOCUMENT_MANAGER_ROLE");
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");
    
    // Role membership tracking
    mapping(bytes32 => mapping(address => bool)) public roleMembers;
    mapping(bytes32 => address[]) public roleMembersList;
    mapping(address => bytes32[]) public userRoles;
    
    // Admin address
    address public contractAdmin;
    
    // Events
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    event AdminTransferred(address indexed previousAdmin, address indexed newAdmin);
    
    constructor() {
        contractAdmin = msg.sender;
        _grantRole(ADMIN_ROLE, msg.sender);
    }
    
    // Modifiers
    modifier onlyRole(bytes32 role) {
        require(hasRole(role, msg.sender), "Access denied: insufficient permissions");
        _;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == contractAdmin, "Only admin can perform this action");
        _;
    }
    
    /**
     * @dev Grant role to address
     */
    function grantRole(bytes32 role, address account) public onlyRole(ADMIN_ROLE) {
        _grantRole(role, account);
    }
    
    /**
     * @dev Internal function to grant role
     */
    function _grantRole(bytes32 role, address account) internal {
        if (!roleMembers[role][account]) {
            roleMembers[role][account] = true;
            roleMembersList[role].push(account);
            userRoles[account].push(role);
            emit RoleGranted(role, account, msg.sender);
        }
    }
    
    /**
     * @dev Revoke role from address
     */
    function revokeRole(bytes32 role, address account) public onlyRole(ADMIN_ROLE) {
        if (roleMembers[role][account]) {
            roleMembers[role][account] = false;
            emit RoleRevoked(role, account, msg.sender);
        }
    }
    
    /**
     * @dev Check if address has role
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return roleMembers[role][account];
    }
    
    /**
     * @dev Get all members of a role
     */
    function getRoleMembers(bytes32 role) public view returns (address[] memory) {
        return roleMembersList[role];
    }
    
    /**
     * @dev Get all roles for an address
     */
    function getUserRoles(address user) public view returns (bytes32[] memory) {
        return userRoles[user];
    }
    
    /**
     * @dev Transfer admin privileges
     */
    function transferAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "Invalid admin address");
        address previousAdmin = contractAdmin;
        contractAdmin = newAdmin;
        _grantRole(ADMIN_ROLE, newAdmin);
        emit AdminTransferred(previousAdmin, newAdmin);
    }
}
