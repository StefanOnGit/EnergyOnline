pragma solidity ^0.4.19;

contract Policy {
    /* Helper function that decides if the Origin should give some Tokens away */
    function grantTokens(address target, uint256 amount) public view returns(bool);
}

contract Origin {
    /* Variable to prevent reentrant bugs */
    bool reenter;
    
    /* The token amount for every account */
    mapping(address => uint256) balance;
    
    /* The address of the actual policy */
    address tokenPolicy;
    
    /* Just a constructor */
    function Tokens() public {
        /* Initialize the balance of the origin */
        balance[address(this)] = 1e40;
    }
    
    /* Event that will be called on every transfer */
    event Transfer(address source, address target, uint256 amount);
    
    /* Function to transfer tokens from one account to another */
    function transfer(address target, uint256 amount) public {
        require(reenter == false);
        reenter = true;
        
        /* Source (= Caller) needs enough balance on account */
        require(balance[msg.sender] >= amount);
        /* Do the transfer */
        balance[msg.sender] -= amount;
        balance[target] += amount;
        /* Fire a transfer-event for eventual listeners */
        Transfer(msg.sender, target, amount);
        
        reenter = false;
    }
    
    /* Ask the origin for some tokens */
    function requestTokens(address target, uint256 amount) public {
        require(reenter == false);
        reenter = true;
        
        /* According to the policy your demand will be declined */
        require(Policy(tokenPolicy).grantTokens(target, amount));
        /* Start the transaction */
        /* This can still fail if the balance of the origin is too low */
        
        reenter = false;
        
        transfer(target, amount);
    }
    reenter
    /* There should be a mechanism that can decide about the policy */
    function setTokenPolicy(address tokenPolicy) public {
        require(SOMETHING); //                                                   <--- Critical Point
        /* Request accepted replace tokenPolicy */
        tokenPolicy = tokenPolicy;
    }
}
