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
import "./TestLib.sol";


// ----------------------------------------------------------------------------
// Pizza Coin Contract
// ----------------------------------------------------------------------------
contract PizzaCoin is /*ERC20,*/ Owned {
    using BasicStringUtils for string;

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

        /*TestLib.executeConstructorCode(_ownerName, _voterInitialTokens);

        initStateMap();

        ownerName = _ownerName;
        voterInitialTokens = _voterInitialTokens;*/

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

        TestLib.emitStateChanged(convertStateToString(), _ownerName);
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

        // Allow only a staff transfer the state from Initial to Registration
        // Revert a transaction if the contract does not get initialized completely
        TestLib.doesContractGotCompletelyInitialized(
            staff, staffContract, playerContract, teamContract
        );

        state = State.Registration;

        TestLib.emitStateChanged(convertStateToString(), staffContractInstance);
    }

    // ------------------------------------------------------------------------
    // Allow a staff freeze Registration state and transfer the state to RegistrationLocked
    // ------------------------------------------------------------------------
    function lockRegistration() public onlyRegistrationState onlyStaff {
        state = State.RegistrationLocked;

        TestLib.emitStateChanged(convertStateToString(), staffContractInstance);
    }

    // ------------------------------------------------------------------------
    // Allow a staff transfer a state from RegistrationLocked to Voting
    // ------------------------------------------------------------------------
    function startVoting() public onlyRegistrationLockedState onlyStaff {
        state = State.Voting;

        TestLib.emitStateChanged(convertStateToString(), staffContractInstance);
    }

    // ------------------------------------------------------------------------
    // Allow a staff transfer a state from Voting to VotingFinished
    // ------------------------------------------------------------------------
    function stopVoting() public onlyVotingState onlyStaff {
        state = State.VotingFinished;

        TestLib.emitStateChanged(convertStateToString(), staffContractInstance);
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

        // Register an owner as a staff. We cannot use calling to registerStaff() 
        // because the contract state is Initial.
        TestLib.registerStaff(owner, ownerName, staffContract);
    }

    // ------------------------------------------------------------------------
    // Register a new staff
    // ------------------------------------------------------------------------
    function registerStaff(address _staff, string _staffName) public onlyRegistrationState onlyStaff {
        TestLib.registerStaff(_staff, _staffName, staffContract);
    }

    // ------------------------------------------------------------------------
    // Remove a specific staff
    // ------------------------------------------------------------------------
    function kickStaff(address _staff) public onlyRegistrationState onlyOwner {
        TestLib.kickStaff(_staff, staffContract);
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
        TestLib.registerPlayer(_playerName, _teamName, playerContract, teamContract);
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
        TestLib.createTeam(_teamName, _creatorName, playerContract, teamContract);
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

    // ------------------------------------------------------------------------
    // Remove the first found player in a particular team 
    // (start searching at _startSearchingIndex)
    // ------------------------------------------------------------------------
    function kickFirstFoundTeamPlayer(string _teamName, uint256 _startSearchingIndex) 
        public onlyRegistrationState onlyStaff returns (uint256 _nextStartSearchingIndex, uint256 _totalPlayersRemaining) {

        (_nextStartSearchingIndex, _totalPlayersRemaining) = TestLib.kickFirstFoundTeamPlayer(
            _teamName, _startSearchingIndex, staffContract, playerContract, teamContract);
    }

    // ------------------------------------------------------------------------
    // Remove a specific player from a particular team
    // ------------------------------------------------------------------------
    function kickPlayer(address _player, string _teamName) public onlyRegistrationState onlyStaff {
        TestLib.kickPlayer(_player, _teamName, staffContract, playerContract, teamContract);
    }

                /*// ------------------------------------------------------------------------
                // Get a total number of players in a specified team
                // ------------------------------------------------------------------------
                function getTotalPlayersInTeam(string _teamName) public view returns (uint256 _total) {
                    return TestLib.getTotalPlayersInTeam(_teamName, playerContract, teamContract);
                }*/

    // ------------------------------------------------------------------------
    // Remove a specific team (the team must be empty of players)
    // ------------------------------------------------------------------------
    function kickTeam(string _teamName) public onlyRegistrationState onlyStaff {
        TestLib.kickTeam(_teamName, staffContract, teamContract);
    }

    /*// ------------------------------------------------------------------------
    // Get a total number of players in a specified team
    // ------------------------------------------------------------------------
    function getTotalPlayersInTeam(string _teamName) public view returns (uint256 _total) {
        return teamContractInstance.getTotalPlayersInTeam(_teamName);
    }

    // ------------------------------------------------------------------------
    // Get the first found player of a specified team
    // (start searching at _startSearchingIndex)
    // ------------------------------------------------------------------------
    function getFirstFoundPlayerInTeam(string _teamName, uint256 _startSearchingIndex) 
        public view
        returns (
            bool _endOfList, 
            uint256 _nextStartSearchingIndex,
            address _player
        ) 
    {
        return teamContractInstance.getFirstFoundPlayerInTeam(_teamName, _startSearchingIndex);
    }*/
}