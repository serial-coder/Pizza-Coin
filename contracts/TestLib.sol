/*
* Copyright (c) 2018, Phuwanai Thummavet (serial-coder). All rights reserved.
* Github: https://github.com/serial-coder
* Contact us: mr[dot]thummavet[at]gmail[dot]com
*/

pragma solidity ^0.4.23;

import "./BasicStringUtils.sol";
import "./PizzaCoinStaff.sol";
import "./PizzaCoinPlayer.sol";
import "./PizzaCoinTeam.sol";


// ----------------------------------------------------------------------------
// TestLib Library
// ----------------------------------------------------------------------------
library TestLib {
    //using BasicStringUtils for string;

    /*// Contract events (the 'indexed' keyword cannot be used with any string parameter)
    event StateChanged(string _state, address indexed _staff, string _staffName);

    function executeConstructorCode(string _ownerName, uint256 _voterInitialTokens) public {
        require(
            _ownerName.isEmpty() == false,
            "'_ownerName' might not be empty."
        );

        require(
            _voterInitialTokens > 0,
            "'_voterInitialTokens' must be larger than 0."
        );

        //initStateMap();

        //this.ownerName = _ownerName;
        //this.voterInitialTokens = _voterInitialTokens;

        //emit StateChanged(convertStateToString(), owner, _ownerName);
    }*/




    // Contract events (the 'indexed' keyword cannot be used with any string parameter)
    event StateChanged(string _state, address indexed _staff, string _staffName);
    event StaffRegistered(address indexed _staff, string _staffName);
    event StaffKicked(address indexed _staffToBeKicked, string _staffName, address indexed _kicker, string _kickerName);
    event PlayerRegistered(address indexed _player, string _playerName, string _teamName);
    event TeamCreated(string _teamName, address indexed _creator, string _creatorName);
    event PlayerKicked(address indexed _playerToBeKicked, string _playerName, 
        string _teamName, address indexed _kicker, string _kickerName
    );
    event TeamKicked(string _teamName, address indexed _kicker, string _kickerName);




    function emitStateChanged(string _state, string _staffName) public view {
        address staff = msg.sender;
        emit StateChanged(_state, staff, _staffName);
    }

    function emitStateChanged(string _state, address _staffContract) public view {
        address staff = msg.sender;

        // Get a contract instance from the deployed addresses
        IStaffContract staffContractInstance = IStaffContract(_staffContract);

        string memory staffName = staffContractInstance.getStaffName(staff);
        emit StateChanged(_state, staff, staffName);
    }

    function registerStaff(address _staff, string _staffName, address _staffContract) public view {

        // Get a contract instance from the deployed addresses
        IStaffContract staffContractInstance = IStaffContract(_staffContract);

        staffContractInstance.registerStaff(_staff, _staffName);
        emit StaffRegistered(_staff, _staffName);
    }

    function kickStaff(address _staff, address _staffContract) public view {

        // Get a contract instance from the deployed addresses
        IStaffContract staffContractInstance = IStaffContract(_staffContract);

        staffContractInstance.kickStaff(_staff);

        address kicker = msg.sender;
        string memory staffName = staffContractInstance.getStaffName(_staff);
        string memory kickerName = staffContractInstance.getStaffName(kicker);
        emit StaffKicked(_staff, staffName, kicker, kickerName);
    }

    function registerPlayer(string _playerName, string _teamName, address _playerContract, address _teamContract) public view {
        address player = msg.sender;

        // Get contract instances from the deployed addresses
        IPlayerContract playerContractInstance = IPlayerContract(_playerContract);
        ITeamContract teamContractInstance = ITeamContract(_teamContract);

        playerContractInstance.registerPlayer(player, _playerName, _teamName);

        // Add a player to a team he/she associates with
        teamContractInstance.registerPlayerToTeam(player, _teamName);

        emit PlayerRegistered(player, _playerName, _teamName);
    }

    function createTeam(string _teamName, string _creatorName, address _playerContract, address _teamContract) public view {
        address creator = msg.sender;

        // Get a contract instance from the deployed addresses
        ITeamContract teamContractInstance = ITeamContract(_teamContract);
        
        // Create a new team
        teamContractInstance.createTeam(_teamName, creator, _creatorName);

        // Register a creator to a team as team leader
        registerPlayer(_creatorName, _teamName, _playerContract, _teamContract);

        emit TeamCreated(_teamName, creator, _creatorName);
    }

    
    
    
    
    // ------------------------------------------------------------------------
    // Allow only a staff transfer the state from Initial to Registration
    // Revert a transaction if the contract does not get initialized completely
    // ------------------------------------------------------------------------
    function doesContractGotCompletelyInitialized(
        address _staff, 
        address _staffContract,
        address _playerContract,
        address _teamContract
    ) 
    public view
    {   
        require(
            _staffContract != address(0),
            "The staff contract did not get initialized"
        );

        require(
            _playerContract != address(0),
            "The player contract did not get initialized"
        );

        require(
            _teamContract != address(0),
            "The team contract did not get initialized"
        );

        // Get a contract instance from the deployed addresses
        IStaffContract staffContractInstance = IStaffContract(_staffContract);

        // Only a staff is allowed to call this function
        require(
            staffContractInstance.isStaff(_staff) == true,
            "This address is not a staff."
        );
    }

    // ------------------------------------------------------------------------
    // Remove the first found player in a particular team 
    // (start searching at _startSearchingIndex)
    // ------------------------------------------------------------------------
    function kickFirstFoundTeamPlayer(
        string _teamName, 
        uint256 _startSearchingIndex,
        address _staffContract,
        address _playerContract,
        address _teamContract
    ) 
    public view 
    returns (
        uint256 _nextStartSearchingIndex, 
        uint256 _totalPlayersRemaining
    ) {
        require(
            _staffContract != address(0),
            "'_staffContract' contains an invalid address."
        );

        require(
            _playerContract != address(0),
            "'_playerContract' contains an invalid address."
        );

        require(
            _teamContract != address(0),
            "'_teamContract' contains an invalid address."
        );

        // Get contract instances from the deployed addresses
        IPlayerContract playerContractInstance = IPlayerContract(_playerContract);
        ITeamContract teamContractInstance = ITeamContract(_teamContract);

        // Get the array length of players in the specific team,
        // including all ever removal players
        //uint256 noOfAllEverTeamPlayers = teamContractInstance.getArrayLengthOfPlayersInTeam(_teamName);

        require(
            _startSearchingIndex < /*noOfAllEverTeamPlayers*/
                teamContractInstance.getArrayLengthOfPlayersInTeam(_teamName),
            "'_startSearchingIndex' is out of bound."
        );

        _nextStartSearchingIndex = /*noOfAllEverTeamPlayers*/teamContractInstance.getArrayLengthOfPlayersInTeam(_teamName);
        _totalPlayersRemaining = 0;

        for (uint256 i = _startSearchingIndex; i < /*noOfAllEverTeamPlayers*/
            teamContractInstance.getArrayLengthOfPlayersInTeam(_teamName); i++
        ) {
            bool endOfList;  // used as a temporary variable
            address player;

            (endOfList, player) = teamContractInstance.getPlayerInTeamAtIndex(_teamName, i);
            if (playerContractInstance.isPlayerInTeam(player, _teamName) == true) {
                // Remove a specific player
                kickPlayer(player, _teamName, _staffContract, _playerContract, _teamContract);

                // Start next searching at the next array element
                _nextStartSearchingIndex = i + 1;
                _totalPlayersRemaining = teamContractInstance.getTotalPlayersInTeam(_teamName);
                //_totalPlayersRemaining = getTotalPlayersInTeam(_teamName, _playerContract, _teamContract);
                return;     
            }
        }
    }
    
    // ------------------------------------------------------------------------
    // Remove a specific player from a particular team
    // ------------------------------------------------------------------------
    function kickPlayer(
        address _player, 
        string _teamName, 
        address _staffContract,
        address _playerContract,
        address _teamContract
    ) 
    public view 
    {
        require(
            _staffContract != address(0),
            "'_staffContract' contains an invalid address."
        );

        require(
            _playerContract != address(0),
            "'_playerContract' contains an invalid address."
        );

        require(
            _teamContract != address(0),
            "'_teamContract' contains an invalid address."
        );

        // Get contract instances from the deployed addresses
        IStaffContract staffContractInstance = IStaffContract(_staffContract);
        IPlayerContract playerContractInstance = IPlayerContract(_playerContract);
        ITeamContract teamContractInstance = ITeamContract(_teamContract);

        // Remove a player from the player list
        playerContractInstance.kickPlayer(_player, _teamName);

        // Remove a player from the player list of the specified team
        teamContractInstance.kickPlayerOutOffTeam(_player, _teamName);

        address kicker = msg.sender;
        string memory playerName = playerContractInstance.getPlayerName(_player);
        string memory kickerName = staffContractInstance.getStaffName(kicker);
        emit PlayerKicked(_player, playerName, _teamName, kicker, kickerName);
    }

    /*// ------------------------------------------------------------------------
    // Get a total number of players in a specified team
    // ------------------------------------------------------------------------
    function getTotalPlayersInTeam(
        string _teamName,
        address _playerContract,
        address _teamContract
    ) 
    public view 
    returns (
        uint256 _total
    ) {
        require(
            _playerContract != address(0),
            "'_playerContract' contains an invalid address."
        );

        require(
            _teamContract != address(0),
            "'_teamContract' contains an invalid address."
        );

        // Get contract instances from the deployed addresses
        IPlayerContract playerContractInstance = IPlayerContract(_playerContract);
        ITeamContract teamContractInstance = ITeamContract(_teamContract);

        // Get the array length of players in the specific team,
        // including all ever removal players
        uint256 noOfAllEverTeamPlayers = teamContractInstance.getArrayLengthOfPlayersInTeam(_teamName);

        _total = 0;
        for (uint256 i = 0; i < noOfAllEverTeamPlayers; i++) {
            bool endOfList;  // used as a temporary variable
            address player;

            (endOfList, player) = teamContractInstance.getPlayerInTeamAtIndex(_teamName, i);

            // player == address(0) if the player was removed by kickPlayer()
            if (player != address(0) && playerContractInstance.isPlayerInTeam(player, _teamName) == true) {
                _total++;
            }
        }
    }*/


    // ------------------------------------------------------------------------
    // Remove a specific team (the team must be empty of players)
    // ------------------------------------------------------------------------
    function kickTeam(string _teamName, address _staffContract, address _teamContract) public view {
        require(
            _staffContract != address(0),
            "'_staffContract' contains an invalid address."
        );

        require(
            _teamContract != address(0),
            "'_teamContract' contains an invalid address."
        );

        // Get contract instances from the deployed addresses
        IStaffContract staffContractInstance = IStaffContract(_staffContract);
        ITeamContract teamContractInstance = ITeamContract(_teamContract);

        teamContractInstance.kickTeam(_teamName);

        address kicker = msg.sender;
        string memory kickerName = staffContractInstance.getStaffName(kicker);
        emit TeamKicked(_teamName, kicker, kickerName);
    }
}