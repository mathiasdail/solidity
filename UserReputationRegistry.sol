pragma solidity ^0.6.6;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure  returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @dev Interface of the Whitelisting contract
 */
interface IContractWhitelist {
    /**
     * @dev Returns if contract isStakeWhitelisted
     */
    function isStakeWhitelisted(address _address) external view returns (bool);
    /**
     * @dev Returns if contract isRewardWhitelisted
     */
    function isRewardWhitelisted(address _address) external view returns (bool);
    /**
     * @dev Returns if contract isReputationWhitelisted
     */
    function isReputationWhitelisted(address _address) external view returns (bool);
}

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/access/Ownable.sol";

/**
 * User name registry
 *
 * Names are available for free, on a first come first served basis.
 * Names are bytes32 rather than strings, since dynamic-sized keys in
 * mappings aren't supported.
 */
contract User_Reputation_Registry is Ownable{
    event UserRegistered(bytes32 name, uint256 timestamp);
    event UserTransferred(bytes32 name);
    //event UserDeleted(bytes32);

    using SafeMath for uint;
    struct User {
        bytes32 name;
        address owner;
    }
    address whitelist_address = 0x7CD16b228f58a34E9860ee26533a5DF1A6E6E899;
    IContractWhitelist public whitelist  = IContractWhitelist(whitelist_address);
    
    mapping (address => bool) public registered;
    mapping (bytes32 => User) public users;
    
    
    mapping(address => uint256) public reputation; // maps user's address to voteToken balance
    
    
    
    // ---------- EXTERNAL reputation calls ----------
    
    /**
     * @notice A method for a verified whitelisted contract to allocate for itself some stake
     */
    function ProxyAddReputation(uint256 rep, address _stakeholder)
        public
        returns(bool)
    {
        require(whitelist.isReputationWhitelisted(msg.sender));

        bool allocation_succeeded = true;
        
        
        reputation[_stakeholder] = reputation[_stakeholder].add(rep);
            
        return allocation_succeeded;
        
    }
    
    
    /**
     * @notice A method for a verified whitelisted contract to allocate for itself some stake
     * _StakeToDeallocate has to be equal to the amount of at least one ALLOCATED allocation
     * else the procedure will fail
     */
    function ProxyRemoveReputation(uint256 rep, address _stakeholder)
        public
        returns(bool)
    {
        require(whitelist.isReputationWhitelisted(msg.sender));
        bool deallocation_succeeded = true;
        
        
        reputation[_stakeholder] = reputation[_stakeholder].sub(rep);
            
        return deallocation_succeeded;
    }
    
    
    /**
     * @notice A method for a verified whitelisted contract to allocate for itself some stake
     */
    function OwnerAddReputation(uint256 rep, address _stakeholder)
        public
        onlyOwner
    {
        reputation[_stakeholder] = reputation[_stakeholder].add(rep);
    }
    
    
    /**
     * @notice A method for a verified whitelisted contract to allocate for itself some stake
     */
    function OwnerRemoveReputation(uint256 rep, address _stakeholder)
        public
        onlyOwner
    {
        reputation[_stakeholder] = reputation[_stakeholder].sub(rep);
    }
    
    
    /**
     * @notice A method for a verified whitelisted contract to allocate for itself some stake
     */
    function OwnerResetReputation(address _stakeholder)
        public
        onlyOwner
    {
        reputation[_stakeholder] = 0;
    }
    
    
    
    
    modifier onlyOwnName(bytes32 name) {
        require(name != 0, "Empty name is not owned by anyone.");
        require(users[name].owner == msg.sender, "Sender does not own name.");
        // TODO: wait a second, I thought accessing a struct's field from a mapping like that isn't possible!?
        // why does this (seem to) work?
        _;
    }

    function nameIsValid(bytes32 name) public pure returns(bool) {
        return name != 0;
    }

    function nameIsTaken(bytes32 name) public view returns(bool) {
        User storage maybeEmpty = users[name];
        return maybeEmpty.owner != address(0);
    }

    function nameIsAvailable(bytes32 name) public view returns(bool) {
        return (nameIsValid(name) && !nameIsTaken(name));
    }

    // convenience function mainly for other contracts
    function isOwner(address claimedOwner, bytes32 userName) public view returns(bool) {
        return users[userName].owner == claimedOwner;
    }

    function register(bytes32  name) public {
        _register(User(name, msg.sender));
    }


    function transfer(bytes32 name, address newOwner) public onlyOwnName(name) {
        _transfer(name, newOwner);
    }


    function _register(User memory user) private {
        require(user.name != bytes32(0), "Name must be non-zero.");
        require(user.owner != address(0), "Owner address must be non-zero.");

        require(nameIsAvailable(user.name), "Name already taken or invalid.");

        users[user.name] = user;
        emit UserRegistered(user.name, now);
    }
    

    function _transfer(bytes32 name, address newOwner) private {
        users[name].owner = newOwner;
        emit UserTransferred(name);
    }
}
