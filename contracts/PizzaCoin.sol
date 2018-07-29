/*
* Copyright (c) 2018, Phuwanai Thummavet (serial-coder). All rights reserved.
* Github: https://github.com/serial-coder
* Contact us: mr[dot]thummavet[at]gmail[dot]com
*/

pragma solidity ^0.4.23;

import "./ERC20.sol";
//import "./SafeMath.sol";
import "./BasicStringUtils.sol";
import "./Owned.sol";
import "./PizzaCoinStaff.sol";
import "./PizzaCoinPlayer.sol";
import "./PizzaCoinTeam.sol";
import "./PizzaCoinStaffDeployer.sol";
import "./PizzaCoinPlayerDeployer.sol";
import "./PizzaCoinTeamDeployer.sol";


// ----------------------------------------------------------------------------
// Pizza Coin Contract
// ----------------------------------------------------------------------------
contract PizzaCoin is /*ERC20,*/ Owned {
    using BasicStringUtils for string;

    // Contract events (the 'indexed' keyword cannot be used with any string parameter)
    event StateChanged(string _state, address indexed _staff, string _staffName);
    event StaffRegistered(address indexed _staff, string _staffName);
    event StaffKicked(address indexed _staffToBeKicked, string _staffName, address indexed _kicker, string _kickerName);
    event PlayerRegistered(address indexed _player, string _playerName, string _teamName);
    event TeamCreated(string _teamName, address indexed _creator, string _creatorName);

    // Token info
    string public constant symbol = "PZC";
    string public constant name = "Pizza Coin";
    uint8 public constant decimals = 0;

    string private ownerName;
    uint256 public voterInitialTokens;

    address private staffContract;
    IStaffContract private staffContractInstance;

    address private playerContract;
    IPlayerContract private playerContractInstance;

    address private teamContract;
    ITeamContract private teamContractInstance;

    enum State { Initial, Registration, RegistrationLocked, Voting, VotingFinished }
    State private state = State.Initial;

    // mapping(keccak256(state) => stateInString)
    mapping(bytes32 => string) private stateMap;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor(string _ownerName, uint256 _voterInitialTokens) public {
        require(
            _ownerName.isEmpty() == false,
            "'_ownerName' might not be empty."
        );

        require(
            _voterInitialTokens > 0,
            "'_voterInitialTokens' must be larger than 0."
        );

        initStateMap();

        ownerName = _ownerName;
        voterInitialTokens = _voterInitialTokens;

        emit StateChanged(convertStateToString(), owner, _ownerName);
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert("We don't accept ETH.");
    }

    // ------------------------------------------------------------------------
    // Guarantee that msg.sender has not been registered before
    // ------------------------------------------------------------------------
    modifier notRegistered {
        require(
            staffContractInstance.isStaff(msg.sender) == false && 
            playerContractInstance.isPlayer(msg.sender) == false,
            "This address was registered already."
        );
        _;
    }

    // ------------------------------------------------------------------------
    // Guarantee that msg.sender must be a staff
    // ------------------------------------------------------------------------
    modifier onlyStaff {
        require(
            staffContractInstance.isStaff(msg.sender) == true || msg.sender == owner,
            "This address is not a staff."
        );
        _;
    }

    // ------------------------------------------------------------------------
    // Guarantee that the present state is Initial
    // ------------------------------------------------------------------------
    modifier onlyInitialState {
        require(
            state == State.Initial,
            "The present state is not Initial."
        );
        _;
    }

    // ------------------------------------------------------------------------
    // Guarantee that the present state is Registration
    // ------------------------------------------------------------------------
    modifier onlyRegistrationState {
        require(
            state == State.Registration,
            "The present state is not Registration."
        );
        _;
    }

    // ------------------------------------------------------------------------
    // Guarantee that the present state is RegistrationLocked
    // ------------------------------------------------------------------------
    modifier onlyRegistrationLockedState {
        require(
            state == State.RegistrationLocked,
            "The present state is not RegistrationLocked."
        );
        _;
    }

    // ------------------------------------------------------------------------
    // Guarantee that the present state is Voting
    // ------------------------------------------------------------------------
    modifier onlyVotingState {
        require(
            state == State.Voting,
            "The present state is not Voting."
        );
        _;
    }

    // ------------------------------------------------------------------------
    // Guarantee that the present state is VotingFinished
    // ------------------------------------------------------------------------
    modifier onlyVotingFinishedState {
        require(
            state == State.VotingFinished,
            "The present state is not VotingFinished."
        );
        _;
    }

    // ------------------------------------------------------------------------
    // Initial a state mapping
    // ------------------------------------------------------------------------
    function initStateMap() internal onlyInitialState onlyOwner {
        stateMap[keccak256(State.Initial)] = "Initial";
        stateMap[keccak256(State.Registration)] = "Registration";
        stateMap[keccak256(State.RegistrationLocked)] = "Registration Locked";
        stateMap[keccak256(State.Voting)] = "Voting";
        stateMap[keccak256(State.VotingFinished)] = "Voting Finished";
    }

    // ------------------------------------------------------------------------
    // Convert a state to a readable string
    // ------------------------------------------------------------------------
    function convertStateToString() internal view returns (string _state) {
        return stateMap[keccak256(state)];
    }

    // ------------------------------------------------------------------------
    // Get a contract state in String format
    // ------------------------------------------------------------------------
    function getContractState() public view returns (string _state) {
        return convertStateToString();
    }

    // ------------------------------------------------------------------------
    // Allow a staff transfer the state from Initial to Registration
    // ------------------------------------------------------------------------
    function startRegistration() public onlyInitialState {
        address staff = msg.sender;

        require(
            staffContract != address(0),
            "The staff contract did not get initialized"
        );

        require(
            playerContract != address(0),
            "The player contract did not get initialized"
        );

        require(
            teamContract != address(0),
            "The team contract did not get initialized"
        );

        // Only a staff is allowed to call this function
        require(
            staffContractInstance.isStaff(staff) == true,
            "This address is not a staff."
        );

        state = State.Registration;

        string memory staffName = staffContractInstance.getStaffName(staff);
        emit StateChanged(convertStateToString(), staff, staffName);
    }

    // ------------------------------------------------------------------------
    // Create a staff contract
    // ------------------------------------------------------------------------
    function createStaffContract() public onlyInitialState onlyOwner {
        require(
            staffContract == address(0),
            "The staff contract got initialized already."
        );

        // Create a staff contract
        staffContract = PizzaCoinStaffDeployer.deployContract(voterInitialTokens);
        PizzaCoinStaffDeployer.transferOwnership(staffContract, this);

        // Get a staff contract instance from the deployed address
        staffContractInstance = IStaffContract(staffContract);

        // Register an owner as a staff
        staffContractInstance.registerStaff(owner, ownerName);
        emit StaffRegistered(owner, ownerName);
    }

    // ------------------------------------------------------------------------
    // Register a new staff
    // ------------------------------------------------------------------------
    function registerStaff(address _staff, string _staffName) public onlyRegistrationState onlyStaff {

        staffContractInstance.registerStaff(_staff, _staffName);
        emit StaffRegistered(_staff, _staffName);
    }

    // ------------------------------------------------------------------------
    // Remove a specific staff
    // ------------------------------------------------------------------------
    function kickStaff(address _staff) public onlyRegistrationState onlyOwner {
        require(
            _staff != address(0),
            "'_staff' contains an invalid address."
        );

        staffContractInstance.kickStaff(_staff);

        address kicker = msg.sender;
        string memory staffName = staffContractInstance.getStaffName(_staff);
        string memory kickerName = staffContractInstance.getStaffName(kicker);
        emit StaffKicked(_staff, staffName, kicker, kickerName);
    }

    // ------------------------------------------------------------------------
    // Get a total number of staffs
    // ------------------------------------------------------------------------
    function getTotalStaffs() public view returns (uint256 _total) {
        return staffContractInstance.getTotalStaffs();
    }

    // ------------------------------------------------------------------------
    // Get an info of the first found staff 
    // (start searching at _startSearchingIndex)
    // ------------------------------------------------------------------------
    function getFirstFoundStaffInfo(uint256 _startSearchingIndex) 
        public view
        returns (
            bool _endOfList, 
            uint256 _nextStartSearchingIndex,
            address _staff,
            string _name,
            uint256 _tokensBalance
        ) 
    {
        return staffContractInstance.getFirstFoundStaffInfo(_startSearchingIndex);
    }

    // ------------------------------------------------------------------------
    // Get a total number of the votes ('teamsVoted' array) made by the specified staff
    // ------------------------------------------------------------------------
    function getTotalVotesByStaff(address _staff) public view returns (uint256 _total) {
        return staffContractInstance.getTotalVotesByStaff(_staff);
    }

    // ------------------------------------------------------------------------
    // Get a team voting result (at the index of 'teamsVoted' array) made by the specified staff
    // ------------------------------------------------------------------------
    function getVoteResultAtIndexByStaff(address _staff, uint256 _votingIndex) 
        public view
        returns (
            bool _endOfList,
            string _team,
            uint256 _voteWeight
        ) 
    {
        return staffContractInstance.getVoteResultAtIndexByStaff(_staff, _votingIndex);
    }

    // ------------------------------------------------------------------------
    // Create a player contract
    // ------------------------------------------------------------------------
    function createPlayerContract() public onlyInitialState onlyOwner {
        require(
            playerContract == address(0),
            "The player contract got initialized already."
        );

        // Create a player contract
        playerContract = PizzaCoinPlayerDeployer.deployContract(voterInitialTokens);
        PizzaCoinPlayerDeployer.transferOwnership(playerContract, this);

        // Get a player contract instance from the deployed address
        playerContractInstance = IPlayerContract(playerContract);
    }

    // ------------------------------------------------------------------------
    // Register a player
    // ------------------------------------------------------------------------
    function registerPlayer(string _playerName, string _teamName) public onlyRegistrationState notRegistered {
        address player = msg.sender;

        playerContractInstance.registerPlayer(player, _playerName, _teamName);

        // Add a player to a team he/she associates with
        teamContractInstance.registerPlayerToTeam(player, _teamName);

        emit PlayerRegistered(player, _playerName, _teamName);
    }

    // ------------------------------------------------------------------------
    // Get a total number of players
    // ------------------------------------------------------------------------
    function getTotalPlayers() public view returns (uint256 _total) {
        return playerContractInstance.getTotalPlayers();
    }

    // ------------------------------------------------------------------------
    // Get an info of the first found player 
    // (start searching at _startSearchingIndex)
    // ------------------------------------------------------------------------
    function getFirstFoundPlayerInfo(uint256 _startSearchingIndex) 
        public view
        returns (
            bool _endOfList, 
            uint256 _nextStartSearchingIndex,
            address _player,
            string _name,
            uint256 _tokensBalance,
            string _teamName
        ) 
    {
        return playerContractInstance.getFirstFoundPlayerInfo(_startSearchingIndex);
    }

    // ------------------------------------------------------------------------
    // Get a total number of the votes ('teamsVoted' array) made by the specified player
    // ------------------------------------------------------------------------
    function getTotalVotesByPlayer(address _player) public view returns (uint256 _total) {
        return playerContractInstance.getTotalVotesByPlayer(_player); 
    }

    // ------------------------------------------------------------------------
    // Get a team voting result (at the index of 'teamsVoted' array) made by the specified player
    // ------------------------------------------------------------------------
    function getVoteResultAtIndexByPlayer(address _player, uint256 _votingIndex) 
        public view
        returns (
            bool _endOfList,
            string _team,
            uint256 _voteWeight
        ) 
    {
        return playerContractInstance.getVoteResultAtIndexByPlayer(_player, _votingIndex);
    }

    // ------------------------------------------------------------------------
    // Create a team contract
    // ------------------------------------------------------------------------
    function createTeamContract() public onlyInitialState onlyOwner {
        require(
            teamContract == address(0),
            "The team contract got initialized already."
        );

        // Create a team contract
        teamContract = PizzaCoinTeamDeployer.deployContract();
        PizzaCoinTeamDeployer.transferOwnership(teamContract, this);

        // Get a team contract instance from the deployed address
        teamContractInstance = ITeamContract(teamContract);
    }

    // ------------------------------------------------------------------------
    // Team leader creates a team
    // ------------------------------------------------------------------------
    function createTeam(string _teamName, string _creatorName) public onlyRegistrationState notRegistered {
        address creator = msg.sender;
        
        // Create a new team
        teamContractInstance.createTeam(_teamName, creator, _creatorName);

        // Register a creator to a team as team leader
        registerPlayer(_creatorName, _teamName);

        emit TeamCreated(_teamName, creator, _creatorName);
    }

    // ------------------------------------------------------------------------
    // Get a total number of teams
    // ------------------------------------------------------------------------
    function getTotalTeams() public view returns (uint256 _total) {
        return teamContractInstance.getTotalTeams();
    }

    // ------------------------------------------------------------------------
    // Get an info of the first found team 
    // (start searching at _startSearchingIndex)
    // ------------------------------------------------------------------------
    function getFirstFoundTeamInfo(uint256 _startSearchingIndex) 
        public view
        returns (
            bool _endOfList, 
            uint256 _nextStartSearchingIndex,
            string _teamName,
            uint256 _totalVoted
        ) 
    {
        return teamContractInstance.getFirstFoundTeamInfo(_startSearchingIndex);
    }

    // ------------------------------------------------------------------------
    // Get a total number of voters to a specified team
    // ------------------------------------------------------------------------
    function getTotalVotersToTeam(string _teamName) public view returns (uint256 _total) {
        return teamContractInstance.getTotalVotersToTeam(_teamName);
    }

    // ------------------------------------------------------------------------
    // Get a voting result (by the index of voters) to a specified team
    // ------------------------------------------------------------------------
    function getVoteResultAtIndexToTeam(string _teamName, uint256 _voterIndex) 
        public view
        returns (
            bool _endOfList,
            address _voter,
            uint256 _voteWeight
        ) 
    {
        return teamContractInstance.getVoteResultAtIndexToTeam(_teamName, _voterIndex);
    }
}