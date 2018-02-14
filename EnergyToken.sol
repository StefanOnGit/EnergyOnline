pragma solidity ^0.4.19;

// The core contract that holds the balance and has a simple and proofable correct interface
contract EnergyToken {
    
    /* For each owner and token_type, there is the possibility to store the balance */
    mapping (address => mapping(address => uint256)) balances;
    
    /* Moves tokens of a token_type from the sender to the destination */
    function transfer_to(address destination, address token_type, uint256 amount) public {
        require(balances[msg.sender][token_type] >= amount);                                // Prevent underflow
        require(balances[destination][token_type] <= uint256(0) - uint256(1) - amount);     // Prevent overflow
        balances[msg.sender][token_type] -= amount;                                         // Subtract tokens of senders account
        balances[destination][token_type] += amount;                                        // Add tokens to destination account
    }
    
    /* Creates new tokens - unique for each different caller */
    function generate_tokens(address destination, uint256 amount) public {
        require(balances[destination][msg.sender] <= uint256(0) - uint256(1) - amount);     // Prevent overflow
        balances[destination][msg.sender] += amount;                                        // Add tokens of sender_type to destination account
    }
    
    /* Destroys some of the own tokens */
    function use_tokens(address token_type, uint256 amount) public {
        require(balances[msg.sender][token_type] >= amount);                                // Prevent underflow
        balances[msg.sender][token_type] -= amount;                                         // Remove tokens of token_type from sender account
    }
    
}
