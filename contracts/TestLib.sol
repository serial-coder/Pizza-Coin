/*
* Copyright (c) 2018, Phuwanai Thummavet (serial-coder). All rights reserved.
* Github: https://github.com/serial-coder
* Contact us: mr[dot]thummavet[at]gmail[dot]com
*/

pragma solidity ^0.4.23;

import "./PizzaCoinStaff.sol";
import "./PizzaCoinPlayer.sol";
import "./PizzaCoinTeam.sol";


// ----------------------------------------------------------------------------
// TestLib Library
// ----------------------------------------------------------------------------
library TestLib {

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
        address _playerContract,
        address _teamContract
    ) 
    public view 
    returns (
        uint256 _nextStartSearchingIndex, 
        uint256 _totalPlayersRemaining
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

        require(
            _startSearchingIndex < noOfAllEverTeamPlayers,
            "'_startSearchingIndex' is out of bound."
        );

        _nextStartSearchingIndex = noOfAllEverTeamPlayers;
        _totalPlayersRemaining = 0;

        for (uint256 i = _startSearchingIndex; i < noOfAllEverTeamPlayers; i++) {
            bool endOfList;  // used as a temporary variable
            address player;

            (endOfList, player) = teamContractInstance.getPlayerInTeamAtIndex(_teamName, i);
            if (playerContractInstance.isPlayerInTeam(player, _teamName) == true) {
                // Remove a specific player
                kickPlayer(player, _teamName, _playerContract, _teamContract);

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
        address _playerContract,
        address _teamContract
    ) 
    public view 
    {
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

        // Remove a player from the player list
        playerContractInstance.kickPlayer(_player, _teamName);

        // Remove a player from the player list of the specified team
        teamContractInstance.kickPlayerOutOffTeam(_player, _teamName);
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
}