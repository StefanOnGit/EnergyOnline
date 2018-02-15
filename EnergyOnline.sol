pragma solidity ^0.4.19;

/* The main contract for the EnergyToken trading containing the balances */
contract EnergyWallets {
    mapping(address => uint256) balance;
    address owner;
    bool initialized;
    
    /* Constructor that initializes the owner */
    function EnergyWallets() public {
        owner = msg.sender;
    }
    
    /* Function that can be called once by the owner
     * It initalizes one wallet with tokens */
    function initialize(address wallet) public {
        require(msg.sender == owner);
        require(initialized == false);
        initialized = true;
        balance[wallet] = 1e40;
    }
    
    /* Function that takes tokens from one wallet and puts it to another one. 
     * Only callable by the owner of the wallet that looses tokens */
    function pay(address wallet, uint256 amount) public {
        require(balance[msg.sender] >= amount);
        balance[msg.sender] -= amount;
        balance[wallet] += amount;
    }
    
    /* Function to read the balance of a wallet */
    function ask_balance(address wallet) public view returns (uint256) {
        return balance[wallet];
    }
}

/* */
contract Callback {
    function call() public;
}

/* The EWZ contract that has the possibility to trade with people and companies */
contract EWZ {
    bool pending;
    bool addresses_set;
    address wallets;
    address oracle;
    address owner;
    
    /* Constructor that sets the owner */
    function EWZ() public {
        owner = msg.sender;
    }
    
    /* Function that can be called once to set the address of the wallet */
    function set_addresses(address wallets_adr, address oracle_adr) public {
        require(msg.sender == owner);
        require(addresses_set == false);
        addresses_set = true;
        wallets = wallets_adr;
        oracle = oracle_adr;
    }
    
    /* Owner and Oracle callable function to pay some tokens to an address */
    function pay(address wallet, uint256 amount) public {
        require(pending == false);
        require(msg.sender == owner || msg.sender == oracle);
        EnergyWallets(wallets).pay(wallet, amount);
    }

    /* Called when a user wants to sell tokens to ewz. Then EWZ releases and event
     * that should get caught by the oracle, and the oracle should ensure that either
     * the user gets his tokens back (oracle can call 'pay') or the user gets his
     * energy discount in the real world */    
    function sell_tokens_to_ewz(uint256 amount, address callback) public {
        require(pending == false);
        uint256 ewz_wallet_before = EnergyWallets(wallets).ask_balance(address(this));
        pending = true;
        Callback(callback).call();
        pending = false;
        uint256 ewz_wallet_now = EnergyWallets(wallets).ask_balance(address(this));
        require(ewz_wallet_before == ewz_wallet_now - amount);
        Oracle(oracle).user_sold_tokens_to_ewz(msg.sender, amount);
    }
}

contract Oracle {
    address owner;
    address ewz;

    event event_user_sold_tokens_to_ewz(address user, uint256 amount);
    
    function Oracle() public {
        owner = msg.sender;
    }
    
    function set_addresses(address ewz_adr) public {
        require(msg.sender == owner);
        ewz = ewz_adr;
    }
    
    function user_sold_tokens_to_ewz(address user, uint256 amount) public {
        require(msg.sender == address(ewz));
        event_user_sold_tokens_to_ewz(user, amount);
    }
    
    function pay_user(address user, uint256 amount) public {
        require(msg.sender == owner);
        EWZ(ewz).pay(user, amount);
    }
}
