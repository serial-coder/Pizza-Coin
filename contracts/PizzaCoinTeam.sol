/*
* Copyright (c) 2018, Phuwanai Thummavet (serial-coder). All rights reserved.
* Github: https://github.com/serial-coder
* Contact us: mr[dot]thummavet[at]gmail[dot]com
*/

pragma solidity ^0.4.23;

import "./SafeMath.sol";
import "./BasicStringUtils.sol";
import "./Owned.sol";


// ------------------------------------------------------------------------
// Interface for exporting public and external functions of PizzaCoinTeam contract
// ------------------------------------------------------------------------
interface ITeamContract {
    function createTeam(string _teamName, address _creator, string _creatorName) public;
    function registerPlayerToTeam(address _player, string _teamName) public;
    function doesTeamExist(string _teamName) public view returns (bool bTeamExist);
    function getTotalTeams() public view returns (uint256 _total);
    function getFirstFoundTeamInfo(uint256 _startSearchingIndex) 
        public view
        returns (
            bool _endOfList, 
            uint256 _nextStartSearchingIndex,
            string _teamName,
            uint256 _totalVoted
        );
    function getTotalVotersToTeam(string _teamName) public view returns (uint256 _total);
    function getVoteResultAtIndexToTeam(string _teamName, uint256 _voterIndex) 
        public view
        returns (
            bool _endOfList,
            address _voter,
            uint256 _voteWeight
        );
}


// ----------------------------------------------------------------------------
// Pizza Coin Team Contract
// ----------------------------------------------------------------------------
contract PizzaCoinTeam is ITeamContract, Owned {
    /*
    * Owner of the contract is PizzaCoin contract, 
    * not a project deployer (or PizzaCoin's owner)
    */

    using SafeMath for uint256;
    using BasicStringUtils for string;

    // Team with players
    struct TeamInfo {
        bool wasCreated;    // Check if the team was created for uniqueness
        address[] players;  // A list of team members (the first list member is the team leader who creates the team)
        address[] voters;   // A list of staffs and other teams' members who gave votes to this team

        // mapping(voter => votes)
        mapping(address => uint256) votesWeight;  // A collection of team voting weights from each voter (i.e., staffs + other teams' members)
        
        uint256 totalVoted;  // Total voting weight got from voters
    }

    string[] private teams;
    mapping(string => TeamInfo) private teamsInfo;  // mapping(team => TeamInfo)

    enum State { Registration, RegistrationLocked, Voting, VotingFinished }
    State private state = State.Registration;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert("We don't accept ETH.");
    }

    // ------------------------------------------------------------------------
    // Guarantee that msg.sender must be a contract deployer (i.e., PizzaCoin address)
    // ------------------------------------------------------------------------
    modifier onlyPizzaCoin {
        require(msg.sender == owner);  // owner == PizzaCoin address
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
    // Determine if the specified team exists
    // ------------------------------------------------------------------------
    function doesTeamExist(string _teamName) public view onlyPizzaCoin returns (bool bTeamExist) {
        require(
            _teamName.isEmpty() == false,
            "'_teamName' might not be empty."
        );

        return teamsInfo[_teamName].wasCreated;
    }

    // ------------------------------------------------------------------------
    // Team leader creates a team
    // ------------------------------------------------------------------------
    function createTeam(string _teamName, address _creator, string _creatorName) public onlyRegistrationState onlyPizzaCoin {
        require(
            _teamName.isEmpty() == false,
            "'_teamName' might not be empty."
        );

        require(
            _creator != address(0),
            "'_creator' contains an invalid address."
        );

        require(
            _creatorName.isEmpty() == false,
            "'_creatorName' might not be empty."
        );
        
        require(
            doesTeamExist(_teamName) == false,
            "The given team was created already."
        );

        // Create a new team
        teams.push(_teamName);
        teamsInfo[_teamName] = TeamInfo({
            wasCreated: true,
            players: new address[](0),
            voters: new address[](0),
            totalVoted: 0
            /*
                Omit 'votesWeight'
            */
        });
    }

    // ------------------------------------------------------------------------
    // Register a player to a specific team
    // ------------------------------------------------------------------------
    function registerPlayerToTeam(address _player, string _teamName) public onlyRegistrationState onlyPizzaCoin {
        require(
            _player != address(0),
            "'_player' contains an invalid address."
        );

        require(
            _teamName.isEmpty() == false,
            "'_teamName' might not be empty."
        );

        require(
            doesTeamExist(_teamName) == true,
            "The given team does not exist."
        );

        // Add a player to a team he/she associates with
        teamsInfo[_teamName].players.push(_player);
    }

    // ------------------------------------------------------------------------
    // Get a total number of teams
    // ------------------------------------------------------------------------
    function getTotalTeams() public view onlyPizzaCoin returns (uint256 _total) {
        _total = 0;
        for (uint256 i = 0; i < teams.length; i++) {
            // Team was not removed before
            if (teams[i].isEmpty() == false && doesTeamExist(teams[i]) == true) {
                _total++;
            }
        }
    }

    // ------------------------------------------------------------------------
    // Get an info of the first found team 
    // (start searching at _startSearchingIndex)
    // ------------------------------------------------------------------------
    function getFirstFoundTeamInfo(uint256 _startSearchingIndex) 
        public view onlyPizzaCoin
        returns (
            bool _endOfList, 
            uint256 _nextStartSearchingIndex,
            string _teamName,
            uint256 _totalVoted
        ) 
    {
        _endOfList = true;
        _nextStartSearchingIndex = teams.length;
        _teamName = "";
        _totalVoted = 0;

        if (_startSearchingIndex >= teams.length) {
            return;
        }  

        for (uint256 i = _startSearchingIndex; i < teams.length; i++) {
            string memory teamName = teams[i];

            // Team was not removed before
            if (teamName.isEmpty() == false && doesTeamExist(teamName) == true) {
                _endOfList = false;
                _nextStartSearchingIndex = i + 1;
                _teamName = teamName;
                _totalVoted = teamsInfo[teamName].totalVoted;
                return;
            }
        }
    }

    // ------------------------------------------------------------------------
    // Get a total number of voters to a specified team
    // ------------------------------------------------------------------------
    function getTotalVotersToTeam(string _teamName) public view onlyPizzaCoin returns (uint256 _total) {
        require(
            _teamName.isEmpty() == false,
            "'_teamName' might not be empty."
        );

        require(
            doesTeamExist(_teamName) == true,
            "Cannot find the specified team."
        );

        return teamsInfo[_teamName].voters.length;
    }

    // ------------------------------------------------------------------------
    // Get a voting result (by the index of voters) to a specified team
    // ------------------------------------------------------------------------
    function getVoteResultAtIndexToTeam(string _teamName, uint256 _voterIndex) 
        public view onlyPizzaCoin
        returns (
            bool _endOfList,
            address _voter,
            uint256 _voteWeight
        ) 
    {
        require(
            _teamName.isEmpty() == false,
            "'_teamName' might not be empty."
        );

        require(
            doesTeamExist(_teamName) == true,
            "Cannot find the specified team."
        );

        if (_voterIndex >= teamsInfo[_teamName].voters.length) {
            _endOfList = true;
            _voter = address(0);
            _voteWeight = 0;
            return;
        }

        _endOfList = false;
        _voter = teamsInfo[_teamName].voters[_voterIndex];
        _voteWeight = teamsInfo[_teamName].votesWeight[_voter];
    }
}