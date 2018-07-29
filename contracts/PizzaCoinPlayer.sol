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
// Interface for exporting public and external functions of PizzaCoinPlayer contract
// ------------------------------------------------------------------------
interface IPlayerContract {
    function isPlayer(address _user) public view returns (bool bPlayer);
    function isPlayerInTeam(address _user, string _teamName) public view returns (bool bTeamPlayer);
    function getPlayerName(address _player) public view returns (string _name);
    function registerPlayer(address _player, string _playerName, string _teamName) public;
    function kickPlayer(address _player, string _teamName) public;
    function getTotalPlayers() public view returns (uint256 _total);
    function getFirstFoundPlayerInfo(uint256 _startSearchingIndex) 
        public view
        returns (
            bool _endOfList, 
            uint256 _nextStartSearchingIndex,
            address _player,
            string _name,
            uint256 _tokensBalance,
            string _teamName
        );
    function getTotalVotesByPlayer(address _player) public view returns (uint256 _total);
    function getVoteResultAtIndexByPlayer(address _player, uint256 _votingIndex) 
        public view
        returns (
            bool _endOfList,
            string _team,
            uint256 _voteWeight
        );
}


// ----------------------------------------------------------------------------
// Pizza Coin Player Contract
// ----------------------------------------------------------------------------
contract PizzaCoinPlayer is IPlayerContract, Owned {
    /*
    * Owner of the contract is PizzaCoin contract, 
    * not a project deployer (or PizzaCoin's owner)
    */

    using SafeMath for uint256;
    using BasicStringUtils for string;

    struct PlayerInfo {
        bool wasRegistered;    // Check if a specific player is being registered
        string name;
        uint256 tokensBalance; // Amount of tokens left for voting
        string teamName;       // A team this player associates with
        string[] teamsVoted;   // Record all the teams voted by this player
        
        // mapping(team => votes)
        mapping(string => uint256) votesWeight;  // A collection of teams with voting weight approved by this player
    }

    address[] private players;
    mapping(address => PlayerInfo) private playersInfo;  // mapping(player => PlayerInfo)

    uint256 private voterInitialTokens;
    uint256 private _totalSupply;

    enum State { Registration, RegistrationLocked, Voting, VotingFinished }
    State private state = State.Registration;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor(uint256 _voterInitialTokens) public {
        require(
            _voterInitialTokens > 0,
            "'_voterInitialTokens' must be larger than 0."
        );

        voterInitialTokens = _voterInitialTokens;
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
    // Determine if _user is a player or not
    // ------------------------------------------------------------------------
    function isPlayer(address _user) public view onlyPizzaCoin returns (bool bPlayer) {
        require(
            _user != address(0),
            "'_user' contains an invalid address."
        );

        return playersInfo[_user].wasRegistered;
    }

    // ------------------------------------------------------------------------
    // Determine if _user is a player in the specified _teamName or not
    // ------------------------------------------------------------------------
    function isPlayerInTeam(address _user, string _teamName) public view onlyPizzaCoin returns (bool bTeamPlayer) {
        require(
            _user != address(0),
            "'_user' contains an invalid address."
        );

        require(
            _teamName.isEmpty() == false,
            "'_teamName' might not be empty."
        );

        return (
            playersInfo[_user].wasRegistered == true && 
            playersInfo[_user].teamName.isEqual(_teamName)
        );
    }

    // ------------------------------------------------------------------------
    // Get a player name
    // ------------------------------------------------------------------------
    function getPlayerName(address _player) public view onlyPizzaCoin returns (string _name) {
        require(
            _player != address(0),
            "'_player' contains an invalid address."
        );

        require(
            isPlayer(_player) == true,
            "Cannot find the specified player."
        );

        return playersInfo[_player].name;
    }

    // ------------------------------------------------------------------------
    // Register a player
    // ------------------------------------------------------------------------
    function registerPlayer(address _player, string _playerName, string _teamName) public onlyRegistrationState onlyPizzaCoin {
        require(
            _player != address(0),
            "'_player' contains an invalid address."
        );

        require(
            _playerName.isEmpty() == false,
            "'_playerName' might not be empty."
        );

        require(
            _teamName.isEmpty() == false,
            "'_teamName' might not be empty."
        );

        require(
            playersInfo[_player].wasRegistered == false,
            "The specified player was registered already."
        );

        // Register a new player
        players.push(_player);
        playersInfo[_player] = PlayerInfo({
            wasRegistered: true,
            name: _playerName,
            tokensBalance: voterInitialTokens,
            teamName: _teamName,
            teamsVoted: new string[](0)
            /*
                Omit 'votesWeight'
            */
        });

        _totalSupply = _totalSupply.add(voterInitialTokens);
    }

    // ------------------------------------------------------------------------
    // Remove a specific player from a particular team
    // ------------------------------------------------------------------------
    function kickPlayer(address _player, string _teamName) public onlyRegistrationState onlyPizzaCoin {
        require(
            _player != address(0),
            "'_player' contains an invalid address."
        );

        require(
            _teamName.isEmpty() == false,
            "'_teamName' might not be empty."
        );
        
        require(
            isPlayerInTeam(_player, _teamName) == true,
            "Cannot find the specified player in a given team."
        );

        bool found;
        uint playerIndex;

        (found, playerIndex) = getPlayerIndex(_player);
        if (!found) {
            revert("Cannot find the specified player.");
        }

        // Reset an element to 0 but the array length never decrease (beware!!)
        delete players[playerIndex];

        // Remove a specified player from a mapping
        delete playersInfo[_player];

        _totalSupply = _totalSupply.sub(voterInitialTokens);
    }

    // ------------------------------------------------------------------------
    // Get the index of a specific player found in the array 'players'
    // ------------------------------------------------------------------------
    function getPlayerIndex(address _player) internal view onlyPizzaCoin returns (bool _found, uint256 _playerIndex) {
        assert(_player != address(0));

        _found = false;
        _playerIndex = 0;

        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == _player) {
                _found = true;
                _playerIndex = i;
                return;
            }
        }
    }

    // ------------------------------------------------------------------------
    // Get a total number of players
    // ------------------------------------------------------------------------
    function getTotalPlayers() public view onlyPizzaCoin returns (uint256 _total) {
        _total = 0;
        for (uint256 i = 0; i < players.length; i++) {
            // Player was not removed before
            if (players[i] != address(0) && playersInfo[players[i]].wasRegistered == true) {
                _total++;
            }
        }
    }

    // ------------------------------------------------------------------------
    // Get an info of the first found player 
    // (start searching at _startSearchingIndex)
    // ------------------------------------------------------------------------
    function getFirstFoundPlayerInfo(uint256 _startSearchingIndex) 
        public view onlyPizzaCoin
        returns (
            bool _endOfList, 
            uint256 _nextStartSearchingIndex,
            address _player,
            string _name,
            uint256 _tokensBalance,
            string _teamName
        ) 
    {
        _endOfList = true;
        _nextStartSearchingIndex = players.length;
        _player = address(0);
        _name = "";
        _tokensBalance = 0;
        _teamName = "";

        if (_startSearchingIndex >= players.length) {
            return;
        }  

        for (uint256 i = _startSearchingIndex; i < players.length; i++) {
            address player = players[i];

            // Player was not removed before
            if (player != address(0) && playersInfo[player].wasRegistered == true) {
                _endOfList = false;
                _nextStartSearchingIndex = i + 1;
                _player = player;
                _name = playersInfo[player].name;
                _tokensBalance = playersInfo[player].tokensBalance;
                _teamName = playersInfo[player].teamName;
                return;
            }
        }
    }

    // ------------------------------------------------------------------------
    // Get a total number of the votes ('teamsVoted' array) made by the specified player
    // ------------------------------------------------------------------------
    function getTotalVotesByPlayer(address _player) public view onlyPizzaCoin returns (uint256 _total) {
        require(
            _player != address(0),
            "'_player' contains an invalid address."
        );
        
        require(
            playersInfo[_player].wasRegistered == true,
            "Cannot find the specified player."
        );

        return playersInfo[_player].teamsVoted.length;
    }

    // ------------------------------------------------------------------------
    // Get a team voting result (at the index of 'teamsVoted' array) made by the specified player
    // ------------------------------------------------------------------------
    function getVoteResultAtIndexByPlayer(address _player, uint256 _votingIndex) 
        public view onlyPizzaCoin
        returns (
            bool _endOfList,
            string _team,
            uint256 _voteWeight
        ) 
    {
        require(
            _player != address(0),
            "'_player' contains an invalid address."
        );

        require(
            playersInfo[_player].wasRegistered == true,
            "Cannot find the specified player."
        );

        if (_votingIndex >= playersInfo[_player].teamsVoted.length) {
            _endOfList = true;
            _team = "";
            _voteWeight = 0;
            return;
        }

        _endOfList = false;
        _team = playersInfo[_player].teamsVoted[_votingIndex];
        _voteWeight = playersInfo[_player].votesWeight[_team];
    }
}