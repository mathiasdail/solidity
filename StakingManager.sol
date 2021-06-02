// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/math/SafeMath.sol";

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



contract StakeManager {
    using SafeMath for uint256;

    address tracker_0x_address = 0x1d30b7d803B24498221538dFEc011043FE57De62;
    address whitelist_address = 0x7CD16b228f58a34E9860ee26533a5DF1A6E6E899;
    
    IERC20 public token = IERC20(tracker_0x_address);
    IContractWhitelist public whitelist = IContractWhitelist(whitelist_address);
    
    /**
     * @notice We  require to know who are all the stakeholders.
     */
    address[] internal stakeholders;

    /**
     * @notice Stakeholders account and balances
     */
    mapping ( address => Balances ) public balances;
    
    uint public alloc_idx_nonce = 0;
    
    struct Balances {
        uint256 free_balance;
        uint256 staked_balance;
        uint256 allocated_balance;
    }
    // ---------- STAKES ----------

    

    /**
     * @notice A method for a stakeholder to create a stake.
     * @param _stake The size of the stake to be created.
     */
    function createStake(uint256 _stake)
        public
    {
        require(balances[msg.sender].free_balance >=  _stake);
        if(balances[msg.sender].staked_balance == 0) addStakeholder(msg.sender);
        
        balances[msg.sender].free_balance = balances[msg.sender].free_balance.sub(_stake);
        balances[msg.sender].staked_balance = balances[msg.sender].staked_balance.add(_stake);
    }

    /**
     * @notice A method for a stakeholder to close all available stakes
     */
    function closeAllStakes()
        public
    {
        uint256 staked_amount = balances[msg.sender].staked_balance;
        balances[msg.sender].free_balance = balances[msg.sender].free_balance.add(staked_amount);
        balances[msg.sender].staked_balance = balances[msg.sender].staked_balance.sub(staked_amount);
    }
    
    
    // ---------- EXTERNAL STAKE ALLOCATIONS ----------
    
    
    /**
     * @notice A method for a verified whitelisted contract to allocate for itself some stake
     */
    function ProxyStakeAllocate(uint256 _StakeAllocation, address _stakeholder)
        public
        returns(bool)
    {
        require(whitelist.isStakeWhitelisted(msg.sender));
        require(isStakeholder(_stakeholder));
        require(balances[_stakeholder].staked_balance >=  _StakeAllocation);
        // check if the contract calling this method has rights to allocate from user stake
        
        balances[_stakeholder].staked_balance = balances[_stakeholder].staked_balance.sub(_StakeAllocation);
        balances[_stakeholder].allocated_balance = balances[_stakeholder].allocated_balance.add(_StakeAllocation);
        return(true);
    }
    
    
    /**
     * @notice A method for a verified whitelisted contract to allocate for itself some stake
     * _StakeToDeallocate has to be equal to the amount of at least one ALLOCATED allocation
     * else the procedure will fail
     */
    function ProxyStakeDeallocate(uint256 _StakeToDeallocate, address _stakeholder)
        public
        returns(bool)
    {
        require(whitelist.isStakeWhitelisted(msg.sender));
        require(isStakeholder(_stakeholder));
        require(balances[_stakeholder].allocated_balance >=  _StakeToDeallocate);
        // check if the contract calling this method has rights to allocate from user stake
        
        balances[_stakeholder].allocated_balance = balances[_stakeholder].allocated_balance.sub(_StakeToDeallocate);
        balances[_stakeholder].staked_balance = balances[_stakeholder].staked_balance.add(_StakeToDeallocate);
        return(true);
    }
    
    
    // ---------- STAKE STATS ----------
    
     /**
     * @notice A method to retrieve the stake for a stakeholder.
     * @param _stakeholder The stakeholder to retrieve the stake for.
     * @return uint256 The amount of wei staked.
     */
    function AvailableStakedAmountOf(address _stakeholder)
        public
        view
        returns(uint256)
    {
        return balances[_stakeholder].staked_balance;
    }
    
     /**
     * @notice A method to retrieve the stake for a stakeholder.
     * @param _stakeholder The stakeholder to retrieve the stake for.
     * @return uint256 The amount of wei staked.
     */
    function AllocatedStakedAmountOf(address _stakeholder)
        public
        view
        returns(uint256)
    {
        return balances[_stakeholder].allocated_balance;
    }

    /**
     * @notice A method to the aggregated stakes from all stakeholders.
     * @return uint256 The aggregated stakes from all stakeholders.
     */
    function TotalStakes()
        public
        view
        returns(uint256)
    {
        uint256 _totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            address user_address = stakeholders[s];
            uint256 user_staked_amount = balances[user_address].staked_balance;
            _totalStakes = _totalStakes.add(user_staked_amount);
        }
        return _totalStakes;
    }
    
    /**
     * @notice A method to the aggregated stakes from all stakeholders.
     * @return uint256 The aggregated stakes from all stakeholders.
     */
    function TotalAllocatedStakes()
        public
        view
        returns(uint256)
    {
        uint256 _totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            address user_address = stakeholders[s];
            uint256 user_alloc_amount = balances[user_address].allocated_balance;
            _totalStakes = _totalStakes.add(user_alloc_amount);
        }
        return _totalStakes;
    }
    
    /**
     * @notice A method to the aggregated stakes from all stakeholders.
     * @return uint256 The aggregated stakes from all stakeholders.
     */
    function TotalAvailableStakes()
        public
        view
        returns(uint256)
    {
        uint256 _totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            address user_address = stakeholders[s];
            uint256 user_free_amount = balances[user_address].free_balance;
            _totalStakes = _totalStakes.add(user_free_amount);
        }
        return _totalStakes;
    }

    // ---------- STAKEHOLDERS ----------

    /**
     * @notice A method to check if an address is a stakeholder.
     * @param _address The address to verify.
     * @return bool, uint256 Whether the address is a stakeholder, 
     * and if so its position in the stakeholders array.
     */
    function isStakeholderIndex(address _address)
        public
        view
        returns(bool, uint256)
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }

    /**
     * @notice A method to check if an address is a stakeholder.
     * @param _address The address to verify.
     * @return bool, uint256 Whether the address is a stakeholder, 
     * and if so its position in the stakeholders array.
     */
    function isStakeholder(address _address)
        public
        view
        returns(bool)
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            if (_address == stakeholders[s]) return true;
        }
        return false;
    }
    /**
     * @notice A method to add a stakeholder.
     * @param _stakeholder The stakeholder to add.
     */
    function addStakeholder(address _stakeholder)
        private
    {
        (bool _isStakeholder, ) = isStakeholderIndex(_stakeholder);
        if(!_isStakeholder) stakeholders.push(_stakeholder);
    }

    /**
     * @notice A method to remove a stakeholder.
     * @param _stakeholder The stakeholder to remove.
     */
    function removeStakeholder(address _stakeholder)
        private
    {
        (bool _isStakeholder, uint256 s) = isStakeholderIndex(_stakeholder);
        if(_isStakeholder){
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        } 
    }

    // ---------- DEPOSIT AND LOCKUP MECHANISMS ----------

    
  function deposit(uint tokens) public {
    require(token.balanceOf(msg.sender) >= tokens);
    // add the deposited tokens into existing balance 
    balances[msg.sender].free_balance += tokens;

    // transfer the tokens from the sender to this contract
    require(token.transferFrom(msg.sender, address(this), tokens));
  }
  
  
    /**
    @notice Withdraw _numTokens ERC20 tokens from the voting contract, revoking these voting rights
    @param _numTokens The number of ERC20 tokens desired in exchange for voting rights
    */
    function withdraw(uint _numTokens) external {
        require(balances[msg.sender].free_balance >= _numTokens);
        balances[msg.sender].free_balance -= _numTokens;
        require(token.transfer(msg.sender, _numTokens));
    }
    
    
    function withdrawAll() public {
        require(balances[msg.sender].free_balance > 0);
        require(token.transfer(msg.sender, balances[msg.sender].free_balance));
        balances[msg.sender].free_balance = 0;
    }
    


}
