pragma solidity ^0.4.19;

contract Origin {
    /* Address that gets all the money that this contract receives */
    address owner;
    
    /* Variable to prevent reentrant bugs */
    bool reenter;
    
    /* The token amount for every account */
    mapping(address => uint256) balance;
    mapping(address => uint256) lastAction;
    
    /* Just a constructor */
    function Tokens() public {
        /* Initialize the balance of the origin */
        balance[address(this)] = 6e39;  // 0.6 * 10^40
        balance[msg.sender] = 4e39;     // 0.4 * 10^40
    }
    
    /* Event that will be called on every transfer */
    event Transfer(address _source, address _target, uint256 _amount);
    
    /* Function to transfer tokens from one account to another */
    function transfer(address _target, uint256 _amount) public {
        require(reenter == false);
        reenter = true;
        
        /* Source (= Caller) needs enough balance on account */
        require(balance[msg.sender] >= _amount);
        
        /* Do the transfer */
        balance[msg.sender] -= _amount;
        balance[_target] += _amount;
        
        /* Update lastAction */
        lastAction[msg.sender] = now;
        lastAction[_target] = now;
        
        /* Fire a transfer-event for eventual listeners */
        Transfer(msg.sender, _target, _amount);
        
        reenter = false;
    }
    
    /* Function to get the current balance of an address */
    function balance_of(address _adr) public view returns(uint256) {
        return balance[_adr];
    }
    
    /* If there is no action on the balance of an address over 2 years the
     * amount of tokens can be taken back (on the owners account) */
    function notifyBlackhole(address _adr) public {
        require(now - lastAction[_adr] >= 2 years);
        require(balance[_adr] > 0);
        balance[owner] += balance[_adr];
        balance[_adr] = 0;
    }
    
    /* Function that changes ether into tokens as long as there are tokens */
    function buyTokens() public payable {
        require(msg.value > 0);
        transfer(msg.sender, msg.value);
    }
    
    /* Called to move ether from this contract to the owner */
    function transferEther() public {
        require(owner == msg.sender);
        require(this.balance > 0);
        owner.transfer(this.balance);
    }
}

contract UserBackend {
    address owner;
    address origin;
    
    function UserBackend() public {
        owner = msg.sender;
    }
    
    function setOrigin(address _origin) public {
        require(owner == msg.sender);
        origin = _origin;
    }
    
    function sendTokens(address _target, uint256 _amount) public {
        require(owner == msg.sender);
        Origin(origin).transfer(_target, _amount);
    }
}
