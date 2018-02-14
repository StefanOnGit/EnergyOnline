pragma solidity ^0.4.19;

contract EWZ {
    /* mapping from balance[owner][energy_type] to amount */
    mapping (address => mapping(uint32 => uint256)) balance;
    
    /* mapping from [energy_type] to price */
    mapping (uint32 => uint256) price; 

    address oracle;
    address owner;
    
    /* constructor */
    function EWZ() public {
        owner = msg.sender;
    }
    
    /* oracle setter (owner only) */
    function set_oracle(address new_oracle) public {
        require(msg.sender == owner);
        oracle = new_oracle;
    }
    
    /* a function that is called by the oracle if the price of an energy_type changed */
    function update_price(uint32 energy_type, uint256 new_price) public {
        require(msg.sender == oracle);
        price[energy_type] = new_price;
    }
    
    /* this function can get called by an oracle, when the user decides to get tokens from his selfproduced energy */
    function trade_energy_into_token (address producer, uint32 energy_type, uint256 amount) public {
        require(msg.sender == oracle);
        require(balance[producer][energy_type] < uint256(0) - amount);
        balance[producer][energy_type] += amount;
    }
    
    /* when the oracle sends the request of the user to trade tokens into energy */
    function trade_tokens_into_energy (address customer, uint32 energy_type, uint256 amount) public {
        require(msg.sender == oracle);
        require(balance[customer][energy_type] >= amount);
        balance[customer][energy_type] -= amount;
    }
    
    /* Everyone can buy tokens for the actual price */
    function buy_tokens(uint32 energy_type, uint256 amount, uint256 expected_price_per_token) public payable {
        require(msg.value > amount * price[energy_type]);
        require(expected_price_per_token == price[energy_type]);
        require(expected_price_per_token > 0);
        require(balance[msg.sender][energy_type] < uint256(0) - amount);
        balance[msg.sender][energy_type] += amount;
    }
    
    /* Everyone can transfer it's own tokens to others */
    function transfer_to(address destination, uint32 energy_type, uint256 amount) public {
        require(balance[msg.sender][energy_type] >= amount);   
        require(balance[destination][energy_type] < uint256(0) - amount);
        balance[msg.sender][energy_type] -= amount;
        balance[destination][energy_type] += amount;
    }
}
