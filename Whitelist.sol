pragma solidity 0.6.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/access/Ownable.sol";

contract Whitelist is Ownable {
  uint8 public constant version = 1;

  mapping (address => bool) private StakeWhitelistMap;
  mapping (address => bool) private RewardWhitelistMap;
  mapping (address => bool) private ReputationWhitelistMap;


  event StakeWhitelisted(address indexed account, bool isWhitelisted);
  event RewardWhitelisted(address indexed account, bool isWhitelisted);
  event ReputationWhitelisted(address indexed account, bool isWhitelisted);

  function isStakeWhitelisted(address _address)
    public
    view
    returns (bool)
  {
    return StakeWhitelistMap[_address];
  }
  
  
  function isRewardWhitelisted(address _address)
    public
    view
    returns (bool)
  {
    return RewardWhitelistMap[_address];
  }
  
  
  function isReputationWhitelisted(address _address)
    public
    view
    returns (bool)
  {
    return ReputationWhitelistMap[_address];
  }


  function addAddress(address _address, bool _allow_Stake, bool _allow_Reward, bool _allow_Reputation)
    public
    onlyOwner
  {
    if( _allow_Stake){
        require(StakeWhitelistMap[_address] != true);
        StakeWhitelistMap[_address] = true;
        emit StakeWhitelisted(_address, true);
        
    }
    if( _allow_Reward){
        require(RewardWhitelistMap[_address] != true);
        RewardWhitelistMap[_address] = true;
        emit RewardWhitelisted(_address, true);
        
    }
    if( _allow_Reputation){
        require(ReputationWhitelistMap[_address] != true);
        ReputationWhitelistMap[_address] = true;
        emit ReputationWhitelisted(_address, true);
    }
  }

  function removeAddress(address _address, bool _disallow_Stake, bool _disallow_Reward, bool _disallow_Reputation )
    public
    onlyOwner
  {
      
    if( _disallow_Stake){
        require(StakeWhitelistMap[_address] != false);
        StakeWhitelistMap[_address] = false;
        emit StakeWhitelisted(_address, false);
        
    }
    if( _disallow_Reward){
        require(RewardWhitelistMap[_address] != false);
        RewardWhitelistMap[_address] = false;
        emit RewardWhitelisted(_address, false);
        
    }
    if( _disallow_Reputation){
        require(ReputationWhitelistMap[_address] != false);
        ReputationWhitelistMap[_address] = false;
        emit ReputationWhitelisted(_address, false);
    }
  }
}
