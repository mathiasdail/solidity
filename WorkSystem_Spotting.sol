/**
 *Submitted for verification at Etherscan.io on 2018-05-24
*/

// File: attrstore/AttributeStore.sol

pragma  solidity  ^0.6.6;

library AttributeStore {
    struct Data {
        mapping(bytes32 => uint) store;
    }

    function getAttribute(Data storage self, bytes32  _UUID, string memory _attrName)
    public view returns (uint) {
        
        bytes32 key = keccak256(abi.encodePacked(_UUID, _attrName));
        return self.store[key];
    }

    function setAttribute(Data storage self, bytes32 _UUID, string memory _attrName, uint _attrVal)
    public {
        bytes32 key = keccak256(abi.encodePacked(_UUID, _attrName));
        self.store[key] = _attrVal;
    }
}

// File: dll/DLL.sol

library DLL {

  uint constant NULL_NODE_ID = 0;

  struct Node {
    uint next;
    uint prev;
  }

  struct Data {
    mapping(uint => Node) dll;
  }

  function isEmpty(Data storage self) public view returns (bool) {
    return getStart(self) == NULL_NODE_ID;
  }

  function contains(Data storage self, uint _curr) public view returns (bool) {
    if (isEmpty(self) || _curr == NULL_NODE_ID) {
      return false;
    } 

    bool isSingleNode = (getStart(self) == _curr) && (getEnd(self) == _curr);
    bool isNullNode = (getNext(self, _curr) == NULL_NODE_ID) && (getPrev(self, _curr) == NULL_NODE_ID);
    return isSingleNode || !isNullNode;
  }

  function getNext(Data storage self, uint _curr) public view returns (uint) {
    return self.dll[_curr].next;
  }

  function getPrev(Data storage self, uint _curr) public view returns (uint) {
    return self.dll[_curr].prev;
  }

  function getStart(Data storage self) public view returns (uint) {
    return getNext(self, NULL_NODE_ID);
  }

  function getEnd(Data storage self) public view returns (uint) {
    return getPrev(self, NULL_NODE_ID);
  }

  /**
  @dev Inserts a new node between _prev and _next. When inserting a node already existing in 
  the list it will be automatically removed from the old position.
  @param _prev the node which _new will be inserted after
  @param _curr the id of the new node being inserted
  @param _next the node which _new will be inserted before
  */
  function insert(Data storage self, uint _prev, uint _curr, uint _next) public {
    require(_curr != NULL_NODE_ID);

    remove(self, _curr);

    require(_prev == NULL_NODE_ID || contains(self, _prev));
    require(_next == NULL_NODE_ID || contains(self, _next));

    require(getNext(self, _prev) == _next);
    require(getPrev(self, _next) == _prev);

    self.dll[_curr].prev = _prev;
    self.dll[_curr].next = _next;

    self.dll[_prev].next = _curr;
    self.dll[_next].prev = _curr;
  }

  function remove(Data storage self, uint _curr) public {
    if (!contains(self, _curr)) {
      return;
    }

    uint next = getNext(self, _curr);
    uint prev = getPrev(self, _curr);

    self.dll[next].prev = prev;
    self.dll[prev].next = next;

    delete self.dll[_curr];
  }
}

// File: localhost/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File: zeppelin/math/SafeMath.sol

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


interface IStakeManager {
    function ProxyStakeAllocate(uint256 _StakeAllocation, address _stakeholder) external returns(bool);
    function ProxyStakeDeallocate(uint256 _StakeToDeallocate, address _stakeholder) external returns(bool);
    //function TotalLockedStakes() external view returns(uint256);
    //function LockedStakedAmountOf(address _stakeholder) external view returns(uint256);
    //function AvailableStakedAmountOf(address _stakeholder) external view returns(uint256);
}


interface IRepManager {
    function ProxyAddReputation(uint256 rep, address _stakeholder) external returns(bool);
    function ProxyRemoveReputation(uint256 rep, address _stakeholder) external returns(bool);
}


interface IRewardManager {
    function ProxyAddReward(uint256 rw, address _stakeholder) external returns(bool);
    function ProxyRemoveRewards(uint256 rw, address _stakeholder) external returns(bool);
}

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/access/Ownable.sol";

/**
@title WorkSystem Spot v0.2
@author Mathias Dail
*/
contract WorkSystem is Ownable {

    // ============
    // EVENTS:
    // ============

    event _VoteCommitted(uint indexed pollID, uint numTokens, address indexed voter);
    event _VoteRevealed(uint indexed pollID, uint numTokens, uint votesFor, uint votesAgainst, uint indexed choice, address indexed voter);
    event _PollCreated(uint voteQuorum, uint commitEndDate, uint revealEndDate, uint indexed pollID, address indexed creator);
    event _HashCertified(bytes32 hash, address indexed creator);
    event _VotingRightsGranted(uint numTokens, address indexed voter);
    event _VotingRightsWithdrawn(uint numTokens, address indexed voter);
    event _TokensRescued(uint indexed pollID, address indexed voter);

    // ============
    // DATA STRUCTURES:
    // ============

    using AttributeStore for AttributeStore.Data;
    using DLL for DLL.Data;
    using SafeMath for uint;
    
    enum HashStatus{
        TBD,
        VALID,
        DELETED
    }
    struct Poll {
        bytes32 hash;                           /// expiration date of commit period for poll
        address author;                         /// author of the proposal
        HashStatus status;                      /// state of the poll
        uint commitEndDate;                     /// expiration date of commit period for poll
        uint revealEndDate;                     /// expiration date of reveal period for poll
        uint voteQuorum;	                    /// number of votes required for a proposal to pass
        uint votesFor;		                    /// tally of votes supporting proposal
        uint votesAgainst;                      /// tally of votes countering proposal
        mapping(address => bool) didCommit;     /// indicates whether an address committed a vote for this poll
        mapping(address => bool) didReveal;     /// indicates whether an address revealed a vote for this poll
    }
    
    struct CertifiedHash {
        uint256 id;                             /// id
        bytes32 hash;                           /// expiration date of commit period for poll
        address author;                         /// author of the proposal 
        uint256 certificationDate;              /// expiration date of reveal period for poll
        uint256 totalVotes;		                /// tally of token votes in this proposal
        uint256 pollID;                         /// associated pollID
    }

    // ============
    // STATE VARIABLES:
    // ============

    uint constant INITIAL_POLL_NONCE = 0;
    uint constant INITIAL_HASH_NONCE = 0;
    uint256 public pollNonce;
    uint public certifiedHashesNonce;
    
    uint public MIN_STAKE;
    uint public MIN_QUORUM;
    uint public MIN_PARTICIPANTS_FOR_VALIDITY;
    uint public COMMIT_ROUND_DURATION;
    uint public REVEAL_ROUND_DURATION;
    
    
    uint public MIN_REWARD_REVEAL = 10 * (10 ** 18);
    uint public MIN_REWARD_POLL = 50 * (10 ** 18);
    uint public MIN_REP_REVEAL = 10 * (10 ** 18);
    uint public MIN_REP_POLL  = 50 * (10 ** 18);
    
    mapping(address => DLL.Data) dllMap;
    AttributeStore.Data store;
    
    mapping(uint => Poll) public pollMap; // maps pollID to Poll struct
    mapping(address => uint256[]) public userPollsMap; // maps user's adresses to pollIDs they started
    mapping(address => uint) public voteTokenBalance; // maps user's address to voteToken balance
    
    CertifiedHash[] public CertifiedHashes;
    
    IERC20 public token;
    IContractWhitelist public whitelist;
    IStakeManager public StakeManager;
    IRepManager public RepManager;
    IRewardManager public RewardManager;

    /**
    @dev Initializer. Can only be called once.
    */
    constructor() public {
        address tracker_0x_address = 0x1d30b7d803B24498221538dFEc011043FE57De62;
        address whitelist_address = 0x7CD16b228f58a34E9860ee26533a5DF1A6E6E899;
        address reputation_mngr_address = 0xc9Cb2b63419254a5Af7aC1eE8EA3996f08f6c33A;
        address reward_mngr_address = 0xD3b4DbC1B4bbDcEb8c5d7e9CAD4acD19838F438f;
        address stake_mngr_address = 0x09FC387Bf4947bA145E429e802dC3FAC7292817C;
        
        token = IERC20(tracker_0x_address);
        whitelist = IContractWhitelist(whitelist_address);
        StakeManager = IStakeManager(stake_mngr_address);
        RepManager  = IRepManager(reputation_mngr_address);
        RewardManager  = IRewardManager(reward_mngr_address);
        
        pollNonce = INITIAL_POLL_NONCE;
        certifiedHashesNonce = INITIAL_HASH_NONCE;
        
        MIN_STAKE = 100 * (10 ** 18);
        MIN_QUORUM = 50;
        MIN_PARTICIPANTS_FOR_VALIDITY = 1;
        COMMIT_ROUND_DURATION = 45;
        REVEAL_ROUND_DURATION = 45;
    }
    

    function updateStakeManager(address addr)
    public
    onlyOwner
    {
        StakeManager = IStakeManager(addr);
    }
    
    function updateRepManager(address addr)
    public
    onlyOwner
    {
        RepManager  = IRepManager(addr);
    }
    
    function updateRewardManager(address addr)
    public
    onlyOwner
    {
        RewardManager  = IRewardManager(addr);
    }
    
    function updateCommitRoundDuration(uint COMMIT_ROUND_DURATION_)
    public
    onlyOwner
    {
        COMMIT_ROUND_DURATION  = COMMIT_ROUND_DURATION_;
    }
    
    function updateRevealRoundDuration(uint REVEAL_ROUND_DURATION_)
    public
    onlyOwner
    {
        REVEAL_ROUND_DURATION  = REVEAL_ROUND_DURATION_;
    }



    // ================
    // TOKEN INTERFACE:
    // ================

    /**
    @notice Loads _numTokens ERC20 tokens into the voting contract for one-to-one voting rights
    @dev Assumes that msg.sender has approved voting contract to spend on their behalf
    @param _numTokens The number of votingTokens desired in exchange for ERC20 tokens
    */
    function requestVotingRights(uint _numTokens) public {
        require(StakeManager.ProxyStakeAllocate(_numTokens, msg.sender));
        voteTokenBalance[msg.sender] += _numTokens;
        emit _VotingRightsGranted(_numTokens, msg.sender);
    }
    
    
    /**
    @notice Withdraw _numTokens ERC20 tokens from the voting contract, revoking these voting rights
    @param _numTokens The number of ERC20 tokens desired in exchange for voting rights
    */
    function withdrawVotingRights(uint _numTokens) external {
        uint availableTokens = voteTokenBalance[msg.sender].sub(getLockedTokens(msg.sender));
        require(availableTokens >= _numTokens);
        require(StakeManager.ProxyStakeDeallocate(_numTokens, msg.sender));
        voteTokenBalance[msg.sender] -= _numTokens;
        emit _VotingRightsWithdrawn(_numTokens, msg.sender);
    }


    /**
    @dev Unlocks tokens locked in unrevealed vote where poll has ended
    @param _pollID Integer identifier associated with the target poll
    */
    function rescueTokens(uint _pollID) public {
        require(isExpired(pollMap[_pollID].revealEndDate));
        require(dllMap[msg.sender].contains(_pollID));

        dllMap[msg.sender].remove(_pollID);
        emit _TokensRescued(_pollID, msg.sender);
    }

    /**
    @dev Unlocks tokens locked in unrevealed votes where polls have ended
    @param _pollIDs Array of integer identifiers associated with the target polls
    */
    function rescueTokensInMultiplePolls(uint[] memory _pollIDs) public {
        // loop through arrays, rescuing tokens from all
        for (uint i = 0; i < _pollIDs.length; i++) {
            rescueTokens(_pollIDs[i]);
        }
    }

    // =================
    // VOTING INTERFACE:
    // =================

    /**
    @notice Commits vote using hash of choice and secret salt to conceal vote until reveal
    @param _pollID Integer identifier associated with target poll
    @param _secretHash Commit keccak256 hash of voter's choice and salt (tightly packed in this order)
    @param _prevPollID The ID of the poll that the user has voted the maximum number of tokens in which is still less than or equal to numTokens
    */
    function commitVote(uint _pollID, bytes32 _secretHash, uint _prevPollID) public {
        require(commitPeriodActive(_pollID));

        //_numTokens The number of tokens to be committed towards the target poll
        uint _numTokens = MIN_STAKE;
        
        // if msg.sender doesn't have enough voting rights,
        // request for enough voting rights
        if (voteTokenBalance[msg.sender] < _numTokens) {
            uint remainder = _numTokens.sub(voteTokenBalance[msg.sender]);
            requestVotingRights(remainder);
        }

        // make sure msg.sender has enough voting rights
        require(voteTokenBalance[msg.sender] >= _numTokens);
        // prevent user from committing to zero node placeholder
        require(_pollID != 0);
        // prevent user from committing a secretHash of 0
        require(_secretHash != 0);

        // Check if _prevPollID exists in the user's DLL or if _prevPollID is 0
        require(_prevPollID == 0 || dllMap[msg.sender].contains(_prevPollID));

        uint nextPollID = dllMap[msg.sender].getNext(_prevPollID);

        // edge case: in-place update
        if (nextPollID == _pollID) {
            nextPollID = dllMap[msg.sender].getNext(_pollID);
        }

        require(validPosition(_prevPollID, nextPollID, msg.sender, _numTokens));
        dllMap[msg.sender].insert(_prevPollID, _pollID, nextPollID);

        bytes32 UUID = attrUUID(msg.sender, _pollID);
        
        string memory nt = "numTokens";
        
        store.setAttribute(UUID,  nt, _numTokens);
        store.setAttribute(UUID, "commitHash", uint(_secretHash));

        pollMap[_pollID].didCommit[msg.sender] = true;
        emit _VoteCommitted(_pollID, _numTokens, msg.sender);
    }
    


    /**
    @notice                 Commits votes using hashes of choices and secret salts to conceal votes until reveal
    @param _pollIDs         Array of integer identifiers associated with target polls
    @param _secretHashes    Array of commit keccak256 hashes of voter's choices and salts (tightly packed in this order)
    @param _prevPollIDs     Array of IDs of the polls that the user has voted the maximum number of tokens in which is still less than or equal to numTokens
    */
    function commitVotes(uint[] calldata  _pollIDs, bytes32[] calldata _secretHashes, uint[] calldata _prevPollIDs) external {
        // make sure the array lengths are all the same
        require(_pollIDs.length == _secretHashes.length);
        require(_pollIDs.length == _prevPollIDs.length);
        
        // loop through arrays, committing each individual vote values
        for (uint i = 0; i < _pollIDs.length; i++) {
            commitVote(_pollIDs[i], _secretHashes[i], _prevPollIDs[i]);
        }
    }

    /**
    @dev Compares previous and next poll's committed tokens for sorting purposes
    @param _prevID Integer identifier associated with previous poll in sorted order
    @param _nextID Integer identifier associated with next poll in sorted order
    @param _voter Address of user to check DLL position for
    @param _numTokens The number of tokens to be committed towards the poll (used for sorting)
    @return valid Boolean indication of if the specified position maintains the sort
    */
    function validPosition(uint _prevID, uint _nextID, address _voter, uint _numTokens) public view returns (bool valid) {
        bool prevValid = (_numTokens >= getNumTokens(_voter, _prevID));
        // if next is zero node, _numTokens does not need to be greater
        bool nextValid = (_numTokens <= getNumTokens(_voter, _nextID) || _nextID == 0);
        return prevValid && nextValid;
    }

    /**
    @notice Reveals vote with choice and secret salt used in generating commitHash to attribute committed tokens
    @param _pollID Integer identifier associated with target poll
    @param _voteOption Vote choice used to generate commitHash for associated poll
    @param _salt Secret number used to generate commitHash for associated poll
    */
    function revealVote(uint _pollID, uint _voteOption, uint _salt) public {
        // Make sure the reveal period is active
        require(revealPeriodActive(_pollID));
        require(pollMap[_pollID].didCommit[msg.sender]);                         // make sure user has committed a vote for this poll
        require(!pollMap[_pollID].didReveal[msg.sender]);                        // prevent user from revealing multiple times
        require(keccak256(abi.encodePacked(_voteOption, _salt)) == getCommitHash(msg.sender, _pollID)); // compare resultant hash from inputs to original commitHash

        uint numTokens = getNumTokens(msg.sender, _pollID);

        if (_voteOption == 1) {// apply numTokens to appropriate poll choice
            pollMap[_pollID].votesFor += numTokens;
        } else {
            pollMap[_pollID].votesAgainst += numTokens;
        }

        dllMap[msg.sender].remove(_pollID); // remove the node referring to this vote upon reveal
        pollMap[_pollID].didReveal[msg.sender] = true;
        
        /// ADD REWARDS AND REPUTATION
        require(RepManager.ProxyAddReputation(MIN_REP_REVEAL, msg.sender));
        require(RewardManager.ProxyAddReward(MIN_REWARD_REVEAL, msg.sender));

        emit _VoteRevealed(_pollID, numTokens, pollMap[_pollID].votesFor, pollMap[_pollID].votesAgainst, _voteOption, msg.sender);
    }

    /**
    @notice             Reveals multiple votes with choices and secret salts used in generating commitHashes to attribute committed tokens
    @param _pollIDs     Array of integer identifiers associated with target polls
    @param _voteOptions Array of vote choices used to generate commitHashes for associated polls
    @param _salts       Array of secret numbers used to generate commitHashes for associated polls
    */
    function revealVotes(uint[] calldata _pollIDs, uint[] calldata _voteOptions, uint[] calldata _salts) external {
        // make sure the array lengths are all the same
        require(_pollIDs.length == _voteOptions.length);
        require(_pollIDs.length == _salts.length);

        // loop through arrays, revealing each individual vote values
        for (uint i = 0; i < _pollIDs.length; i++) {
            revealVote(_pollIDs[i], _voteOptions[i], _salts[i]);
        }
    }

    /**
    @param _pollID Integer identifier associated with target poll
    @param _salt Arbitrarily chosen integer used to generate secretHash
    @return correctVotes Number of tokens voted for winning option
    */
    function getNumPassingTokens(address _voter, uint _pollID, uint _salt) public view returns (uint correctVotes) {
        require(pollEnded(_pollID));
        require(pollMap[_pollID].didReveal[_voter]);

        uint winningChoice = isPassed(_pollID) ? 1 : 0;
        bytes32 winnerHash = keccak256(abi.encodePacked(winningChoice, _salt));
        bytes32 commitHash = getCommitHash(_voter, _pollID);

        require(winnerHash == commitHash);

        return getNumTokens(_voter, _pollID);
    }

    // ==================
    // POLLING INTERFACE:
    // ==================

    /**
    @dev Initiates a poll with canonical configured parameters at pollID emitted by PollCreated event
    */
    function startPoll(bytes32 file_hash) public returns (uint256 pollid_) {
        //_numTokens The number of tokens to be committed towards the target poll
        uint _numTokens = MIN_STAKE;
        
        // if msg.sender doesn't have enough voting rights,
        // request for enough voting rights
        if (voteTokenBalance[msg.sender] < _numTokens) {
            uint remainder = _numTokens.sub(voteTokenBalance[msg.sender]);
            requestVotingRights(remainder);
        }

        // make sure msg.sender has enough voting rights
        require(voteTokenBalance[msg.sender] >= _numTokens);
        // prevent user from committing a secretHash of 0
        require(file_hash != 0);
        
        
        
        pollNonce = pollNonce + 1;
        uint256 test = pollNonce;
        
        //_voteQuorum Type of majority (out of 100) that is necessary for poll to be successful
        uint _voteQuorum = MIN_QUORUM;
        // _commitDuration Length of desired commit period in seconds
        uint _commitDuration = COMMIT_ROUND_DURATION;
        // _revealDuration Length of desired commit period in seconds
        uint _revealDuration = REVEAL_ROUND_DURATION;

        uint commitEndDate = block.timestamp.add(_commitDuration);
        uint revealEndDate = commitEndDate.add(_revealDuration);
        
        userPollsMap[msg.sender].push(pollNonce);

        pollMap[pollNonce] = Poll({
            hash: file_hash,
            status: HashStatus.TBD,
            author: msg.sender,
            voteQuorum: _voteQuorum,
            commitEndDate: commitEndDate,
            revealEndDate: revealEndDate,
            votesFor: 0,
            votesAgainst: 0
        });

        emit _PollCreated(_voteQuorum, commitEndDate, revealEndDate, pollNonce, msg.sender);
        
        return pollNonce;
    }
    
    /**
    @dev Initiates a poll with canonical configured parameters at pollID emitted by PollCreated event
    */
    function dbg(bytes32 file_hash) public returns (uint256 pollid_) {
        //_numTokens The number of tokens to be committed towards the target poll
        uint  _numTokens = MIN_STAKE;
        
        return  pollNonce;
    }
    
    /**
    @notice Trigger the validation of a poll hash; if the poll has ended. If the requirements are valid, 
    the CertifiedHash will be added to the valid list of CertifiedHashes
    @param _pollID Integer identifier associated with target poll
    */
    function ValidatePoll(uint _pollID) public {
        require(pollEnded(_pollID));
        require(isPassed(_pollID));
        // Build CertifiedHashes Struct
        uint token_vote_count = pollMap[_pollID].votesFor + pollMap[_pollID].votesAgainst;
        
        
        CertifiedHash memory ch =  CertifiedHash({
            id:                     certifiedHashesNonce++,
            hash:                   pollMap[_pollID].hash,
            author:                 pollMap[_pollID].author,
            certificationDate:      block.timestamp,
            totalVotes:             token_vote_count,
            pollID:                 _pollID
        });
        
        
        CertifiedHashes.push(ch);
        
        
        /// ADD REWARDS AND REPUTATION
        require(RepManager.ProxyAddReputation(MIN_REP_POLL, pollMap[_pollID].author));
        require(RewardManager.ProxyAddReward(MIN_REWARD_POLL, pollMap[_pollID].author));
        
        emit _HashCertified(pollMap[_pollID].hash, pollMap[_pollID].author);
    }
    
    
    /**
    @notice Trigger the validation of a poll hash; if the poll has ended. If the requirements are valid, 
    the CertifiedHash will be added to the valid list of CertifiedHashes
    @param _pollID Integer identifier associated with target poll
    */
    function getTotalNumberOfVotes(uint _pollID) public view returns (uint vc)  {
        // Build CertifiedHashes Struct
        uint token_vote_count = pollMap[_pollID].votesFor + pollMap[_pollID].votesAgainst;
        return token_vote_count;
    }
    

    /**
    @notice Determines if proposal has passed
    @dev Check if votesFor out of totalVotes exceeds votesQuorum (requires pollEnded)
    @param _pollID Integer identifier associated with target poll
    */
    function isPassed(uint _pollID)  public view returns (bool passed) {
        require(pollEnded(_pollID));

        Poll memory poll = pollMap[_pollID];
        return (100 * poll.votesFor) > (poll.voteQuorum * (poll.votesFor + poll.votesAgainst));
    }

    // ----------------
    // POLLING HELPERS:
    // ----------------

    /**
    @dev Gets the total winning votes for reward distribution purposes
    @param _pollID Integer identifier associated with target poll
    @return numTokens of votes committed to the winning option for specified poll
    */
    function getTotalNumberOfTokensForWinningOption(uint _pollID) public view returns (uint numTokens) {
        require(pollEnded(_pollID));

        if (isPassed(_pollID))
            return pollMap[_pollID].votesFor;
        else
            return pollMap[_pollID].votesAgainst;
    }

    /**
    @notice Determines if poll is over
    @dev Checks isExpired for specified poll's revealEndDate
    @return ended Boolean indication of whether polling period is over
    */
    function pollEnded(uint _pollID) public view returns (bool ended) {
        require(pollExists(_pollID));

        return isExpired(pollMap[_pollID].revealEndDate);
    }
    
    /**
    @notice getUserPolls
    @return user_polls the array of polls started by the user
    */
    function getUserPolls(address user) public view returns (uint256[] memory user_polls) {

        return userPollsMap[user];
    }
    
    /**
    @notice getLastUserPollId
    @return pollId of the last polled a user started
    */
    function getLastUserPollId(address user) public view returns (uint256 pollId) {
        uint256[] memory userPolls = userPollsMap[user];

        return  userPolls[ userPolls.length - 1 ];
    }
    
    /**
    @notice getLastPollId
    @return pollId of the last polled a user started
    */
    function getLastPollId() public view returns (uint256 pollId) {
        return  pollNonce;
    }
    
    /**
    @notice Determines pollCommitEndDate
    @return commitEndDate indication of whether polling period is over
    */
    function pollCommitEndDate(uint _pollID) public view returns (uint256 commitEndDate) {
        require(pollExists(_pollID));

        return pollMap[_pollID].commitEndDate;
    }
    
    
    /**
    @notice Determines pollRevealEndDate
    @return revealEndDate indication of whether polling period is over
    */
    function pollRevealEndDate(uint _pollID) public view returns (uint256 revealEndDate) {
        require(pollExists(_pollID));

        return pollMap[_pollID].revealEndDate;
    }
    
    /**
    @notice Checks if the commit period is still active for the specified poll
    @dev Checks isExpired for the specified poll's commitEndDate
    @param _pollID Integer identifier associated with target poll
    @return active Boolean indication of isCommitPeriodActive for target poll
    */
    function commitPeriodActive(uint _pollID) public view returns (bool active) {
        require(pollExists(_pollID));

        return !isExpired(pollMap[_pollID].commitEndDate);
    }

    /**
    @notice Checks if the reveal period is still active for the specified poll
    @dev Checks isExpired for the specified poll's revealEndDate
    @param _pollID Integer identifier associated with target poll
    */
    function revealPeriodActive(uint _pollID) public view returns (bool active) {
        require(pollExists(_pollID));

        return !isExpired(pollMap[_pollID].revealEndDate) && !commitPeriodActive(_pollID);
    }

    /**
    @dev Checks if user has committed for specified poll
    @param _voter Address of user to check against
    @param _pollID Integer identifier associated with target poll
    @return committed Boolean indication of whether user has committed
    */
    function didCommit(address _voter, uint _pollID) public view returns (bool committed) {
        require(pollExists(_pollID));

        return pollMap[_pollID].didCommit[_voter];
    }

    /**
    @dev Checks if user has revealed for specified poll
    @param _voter Address of user to check against
    @param _pollID Integer identifier associated with target poll
    @return revealed Boolean indication of whether user has revealed
    */
    function didReveal(address _voter, uint _pollID) public view returns (bool revealed) {
        require(pollExists(_pollID));

        return pollMap[_pollID].didReveal[_voter];
    }

    /**
    @dev Checks if a poll exists
    @param _pollID The pollID whose existance is to be evaluated.
    @return exists Boolean Indicates whether a poll exists for the provided pollID
    */
    function pollExists(uint _pollID) public view returns  (bool exists) {
        return (_pollID != 0 && _pollID <= pollNonce);
    }
    


    // ---------------------------
    // DOUBLE-LINKED-LIST HELPERS:
    // ---------------------------

    /**
    @dev Gets the bytes32 commitHash property of target poll
    @param _voter Address of user to check against
    @param _pollID Integer identifier associated with target poll
    @return commitHash Bytes32 hash property attached to target poll
    */
    function getCommitHash(address _voter, uint _pollID)  public view returns (bytes32 commitHash) {
        return bytes32(store.getAttribute(attrUUID(_voter, _pollID), "commitHash"));
    }

    /**
    @dev Wrapper for getAttribute with attrName="numTokens"
    @param _voter Address of user to check against
    @param _pollID Integer identifier associated with target poll
    @return numTokens Number of tokens committed to poll in sorted poll-linked-list
    */
    function getNumTokens(address _voter, uint _pollID)  public view returns (uint numTokens) {
        return store.getAttribute(attrUUID(_voter, _pollID), "numTokens");
    }

    /**
    @dev Gets top element of sorted poll-linked-list
    @param _voter Address of user to check against
    @return pollID Integer identifier to poll with maximum number of tokens committed to it
    */
    function getLastNode(address _voter)  public view returns (uint pollID) {
        return dllMap[_voter].getPrev(0);
    }

    /**
    @dev Gets the numTokens property of getLastNode
    @param _voter Address of user to check against
    @return numTokens Maximum number of tokens committed in poll specified
    */
    function getLockedTokens(address _voter)  public view returns (uint numTokens) {
        return getNumTokens(_voter, getLastNode(_voter));
    }

    /*
    @dev Takes the last node in the user's DLL and iterates backwards through the list searching
    for a node with a value less than or equal to the provided _numTokens value. When such a node
    is found, if the provided _pollID matches the found nodeID, this operation is an in-place
    update. In that case, return the previous node of the node being updated. Otherwise return the
    first node that was found with a value less than or equal to the provided _numTokens.
    @param _voter The voter whose DLL will be searched
    @param _numTokens The value for the numTokens attribute in the node to be inserted
    @return the node which the propoded node should be inserted after
    */
    function getInsertPointForNumTokens(address _voter, uint _numTokens, uint _pollID) public view  returns (uint prevNode) {
      // Get the last node in the list and the number of tokens in that node
      uint nodeID = getLastNode(_voter);
      uint tokensInNode = getNumTokens(_voter, nodeID);

      // Iterate backwards through the list until reaching the root node
      while(nodeID != 0) {
        // Get the number of tokens in the current node
        tokensInNode = getNumTokens(_voter, nodeID);
        if(tokensInNode <= _numTokens) { // We found the insert point!
          if(nodeID == _pollID) {
            // This is an in-place update. Return the prev node of the node being updated
            nodeID = dllMap[_voter].getPrev(nodeID);
          }
          // Return the insert point
          return nodeID; 
        }
        // We did not find the insert point. Continue iterating backwards through the list
        nodeID = dllMap[_voter].getPrev(nodeID);
      }

      // The list is empty, or a smaller value than anything else in the list is being inserted
      return nodeID;
    }

    // ----------------
    // GENERAL HELPERS:
    // ----------------

    /**
    @dev Checks if an expiration date has been reached
    @param _terminationDate Integer timestamp of date to compare current timestamp with
    @return expired Boolean indication of whether the terminationDate has passed
    */
    function isExpired(uint _terminationDate)  public view returns (bool expired) {
        return (block.timestamp > _terminationDate);
    }
    
    /**
    @return keccak256hash  Hash which is deterministic from a and b
    */
    function getHash(uint a, uint b) public pure returns (bytes32 keccak256hash) {
        return keccak256(abi.encodePacked(a, b));
    }
    
    /**
    @return blocktimestamp block.timestamp
    */
    function getBlockTimestamp()  public view returns (uint blocktimestamp) {
        return block.timestamp;
    }


    /**
    @dev Generates an identifier which associates a user and a poll together
    @param _pollID Integer identifier associated with target poll
    @return UUID Hash which is deterministic from _user and _pollID
    */
    function attrUUID(address _user, uint _pollID) public pure returns (bytes32 UUID) {
        return keccak256(abi.encodePacked(_user, _pollID));
    }
}
