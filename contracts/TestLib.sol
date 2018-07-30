/*
* Copyright (c) 2018, Phuwanai Thummavet (serial-coder). All rights reserved.
* Github: https://github.com/serial-coder
* Contact us: mr[dot]thummavet[at]gmail[dot]com
*/

pragma solidity ^0.4.23;

import "./SafeMath.sol";
import "./BasicStringUtils.sol";
import "./PizzaCoinStaff.sol";
import "./PizzaCoinPlayer.sol";
import "./PizzaCoinTeam.sol";


// ----------------------------------------------------------------------------
// TestLib Library
// ----------------------------------------------------------------------------
library TestLib {
    using SafeMath for uint256;
    using BasicStringUtils for string;

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
    event TeamVotedByStaff(string _teamName, address indexed _voter, string _voterName, uint256 _votingWeight);
    event TeamVotedByPlayer(
        string _teamName, address indexed _voter, string _voterName, 
        string _teamVoterAssociatedWith, uint256 _votingWeight
    );


    // ------------------------------------------------------------------------
    // Emit the StateChanged event
    // ------------------------------------------------------------------------
    function emitStateChanged(string _state, string _staffName) public {
        require(
            _state.isEmpty() == false,
            "'_state' might not be empty."
        );

        require(
            _staffName.isEmpty() == false,
            "'_staffName' might not be empty."
        );

        address staff = msg.sender;
        emit StateChanged(_state, staff, _staffName);
    }

    // ------------------------------------------------------------------------
    // Emit the StateChanged event
    // ------------------------------------------------------------------------
    function emitStateChanged(string _state, address _staffContract) public {
        require(
            _state.isEmpty() == false,
            "'_state' might not be empty."
        );

        require(
            _staffContract != address(0),
            "'_staffContract' contains an invalid address."
        );

        address staff = msg.sender;

        // Get a contract instance from the deployed addresses
        IStaffContract staffContractInstance = IStaffContract(_staffContract);

        string memory staffName = staffContractInstance.getStaffName(staff);
        emit StateChanged(_state, staff, staffName);
    }

    // ------------------------------------------------------------------------
    // Register a new staff
    // ------------------------------------------------------------------------
    function registerStaff(address _staff, string _staffName, address _staffContract) public {
        require(
            _staffContract != address(0),
            "'_staffContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        IStaffContract staffContractInstance = IStaffContract(_staffContract);

        staffContractInstance.registerStaff(_staff, _staffName);
        emit StaffRegistered(_staff, _staffName);
    }

    // ------------------------------------------------------------------------
    // Remove a specific staff
    // ------------------------------------------------------------------------
    function kickStaff(address _staff, address _staffContract) public {
        require(
            _staffContract != address(0),
            "'_staffContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        IStaffContract staffContractInstance = IStaffContract(_staffContract);

        staffContractInstance.kickStaff(_staff);

        address kicker = msg.sender;
        string memory staffName = staffContractInstance.getStaffName(_staff);
        string memory kickerName = staffContractInstance.getStaffName(kicker);
        emit StaffKicked(_staff, staffName, kicker, kickerName);
    }

    // ------------------------------------------------------------------------
    // Register a player
    // ------------------------------------------------------------------------
    function registerPlayer(string _playerName, string _teamName, address _playerContract, address _teamContract) public {
        require(
            _playerContract != address(0),
            "'_playerContract' contains an invalid address."
        );

        require(
            _teamContract != address(0),
            "'_teamContract' contains an invalid address."
        );
        
        address player = msg.sender;

        // Get contract instances from the deployed addresses
        IPlayerContract playerContractInstance = IPlayerContract(_playerContract);
        ITeamContract teamContractInstance = ITeamContract(_teamContract);

        playerContractInstance.registerPlayer(player, _playerName, _teamName);

        // Add a player to a team he/she associates with
        teamContractInstance.registerPlayerToTeam(player, _teamName);

        emit PlayerRegistered(player, _playerName, _teamName);
    }

    // ------------------------------------------------------------------------
    // Team leader creates a team
    // ------------------------------------------------------------------------
    function createTeam(string _teamName, string _creatorName, address _playerContract, address _teamContract) public {
        require(
            _playerContract != address(0),
            "'_playerContract' contains an invalid address."
        );

        require(
            _teamContract != address(0),
            "'_teamContract' contains an invalid address."
        );
        
        address creator = msg.sender;

        // Get a contract instance from the deployed addresses
        ITeamContract teamContractInstance = ITeamContract(_teamContract);
        
        // Create a new team
        teamContractInstance.createTeam(_teamName);

        // Register a creator to a team as team leader
        registerPlayer(_creatorName, _teamName, _playerContract, _teamContract);

        emit TeamCreated(_teamName, creator, _creatorName);
    }

    // ------------------------------------------------------------------------
    // Allow only a staff transfer the state from Initial to Registration
    // Revert a transaction if the contract does not get initialized completely
    // ------------------------------------------------------------------------
    function isContractCompletelyInitialized(
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
    public 
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
    public 
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

    // ------------------------------------------------------------------------
    // Remove a specific team (the team must be empty of players)
    // ------------------------------------------------------------------------
    function kickTeam(string _teamName, address _staffContract, address _teamContract) public {
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

    // ------------------------------------------------------------------------
    // Allow any staff or any player in other different teams to vote to a team
    // ------------------------------------------------------------------------
    function voteTeam(
        string _teamName, 
        uint256 _votingWeight, 
        address _staffContract,
        address _playerContract,
        address _teamContract
    ) 
    public 
    {
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

        require(
            _teamName.isEmpty() == false,
            "'_teamName' might not be empty."
        );

        require(
            _votingWeight > 0,
            "'_votingWeight' must be larger than 0."
        );

        require(
            teamContractInstance.doesTeamExist(_teamName) == true,
            "Cannot find the specified team."
        );

        if (staffContractInstance.isStaff(msg.sender)) {
            voteTeamByStaff(_teamName, _votingWeight, _staffContract, _teamContract);  // a staff
        }
        else {
            voteTeamByDifferentTeamPlayer(_teamName, _votingWeight, _playerContract, _teamContract);  // a team player
        }
    }

    // ------------------------------------------------------------------------
    // Vote for a team by a staff
    // ------------------------------------------------------------------------
    function voteTeamByStaff(
        string _teamName, 
        uint256 _votingWeight,
        address _staffContract,
        address _teamContract
    ) 
    internal
    {
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

        address voter = msg.sender;
        assert(_teamName.isEmpty() == false);
        assert(_votingWeight > 0);
        assert(teamContractInstance.doesTeamExist(_teamName) == true);
        assert(staffContractInstance.isStaff(voter));

        require(
            _votingWeight <= staffContractInstance.getTokenBalance(voter),
            "Insufficient voting balance."
        );

        // Staff commits to vote to a team
        staffContractInstance.commitToVote(voter, _votingWeight, _teamName);
        teamContractInstance.voteToTeam(_teamName, voter, _votingWeight);

        string memory voterName = staffContractInstance.getStaffName(voter);
        emit TeamVotedByStaff(_teamName, voter, voterName, _votingWeight);
    }

    // ------------------------------------------------------------------------
    // Vote for a team by a different team player
    // ------------------------------------------------------------------------
    function voteTeamByDifferentTeamPlayer(
        string _teamName, 
        uint256 _votingWeight,
        address _playerContract,
        address _teamContract
    ) 
    internal
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
        
        address voter = msg.sender;
        assert(_teamName.isEmpty() == false);
        assert(_votingWeight > 0);
        assert(teamContractInstance.doesTeamExist(_teamName) == true);
        assert(playerContractInstance.isPlayer(voter));

        require(
            playerContractInstance.isPlayerInTeam(voter, _teamName) == false,
            "A player does not allow to vote to his/her own team."
        );

        require(
            _votingWeight <= playerContractInstance.getTokenBalance(voter),
            "Insufficient voting balance."
        );

        // Player commits to vote to a team
        playerContractInstance.commitToVote(voter, _votingWeight, _teamName);
        teamContractInstance.voteToTeam(_teamName, voter, _votingWeight);

        string memory voterName = playerContractInstance.getPlayerName(voter);
        string memory teamVoterAssociatedWith = playerContractInstance.getTeamNamePlayerJoined(voter);
        emit TeamVotedByPlayer(_teamName, voter, voterName, teamVoterAssociatedWith, _votingWeight);
    }


    /*
    *
    * Our PizzaCoin contract partially complies with ERC token standard #20 interface.
    * That is, only the balanceOf() and totalSupply() will be used.
    *
    */

    // ------------------------------------------------------------------------
    // Standard function of ERC token standard #20
    // ------------------------------------------------------------------------
    function totalSupply(address _staffContract, address _playerContract) public view returns (uint256 _totalSupply) {
        require(
            _staffContract != address(0),
            "'_staffContract' contains an invalid address."
        );

        require(
            _playerContract != address(0),
            "'_playerContract' contains an invalid address."
        );

        // Get contract instances from the deployed addresses
        IStaffContract staffContractInstance = IStaffContract(_staffContract);
        IPlayerContract playerContractInstance = IPlayerContract(_playerContract);

        uint256 staffTotalSupply = staffContractInstance.getTotalSupply();
        uint256 playerTotalSupply = playerContractInstance.getTotalSupply();
        return staffTotalSupply.add(playerTotalSupply);
    }

    // ------------------------------------------------------------------------
    // Standard function of ERC token standard #20
    // ------------------------------------------------------------------------
    function balanceOf(
        address tokenOwner, 
        address _staffContract, 
        address _playerContract
    ) 
    public view 
    returns (uint256 balance) 
    {
        require(
            _staffContract != address(0),
            "'_staffContract' contains an invalid address."
        );

        require(
            _playerContract != address(0),
            "'_playerContract' contains an invalid address."
        );

        // Get contract instances from the deployed addresses
        IStaffContract staffContractInstance = IStaffContract(_staffContract);
        IPlayerContract playerContractInstance = IPlayerContract(_playerContract);

        if (staffContractInstance.isStaff(tokenOwner)) {
            return staffContractInstance.getTokenBalance(tokenOwner);
        }
        else if (playerContractInstance.isPlayer(tokenOwner)) {
            return playerContractInstance.getTokenBalance(tokenOwner);
        }
        else {
            revert("The specified address was not being registered.");
        }
    }

    // ------------------------------------------------------------------------
    // Standard function of ERC token standard #20
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public pure returns (uint256) {
        // This function is never used
        revert("We don't implement this function.");

        // These statements do nothing, just use to stop compilation warnings
        tokenOwner == tokenOwner;
        spender == spender;
    }

    // ------------------------------------------------------------------------
    // Standard function of ERC token standard #20
    // ------------------------------------------------------------------------
    function transfer(address to, uint256 tokens) public pure returns (bool) {
        // This function is never used
        revert("We don't implement this function.");

        // These statements do nothing, just use to stop compilation warnings
        to == to;
        tokens == tokens;
    }

    // ------------------------------------------------------------------------
    // Standard function of ERC token standard #20
    // ------------------------------------------------------------------------
    function approve(address spender, uint256 tokens) public pure returns (bool) {
        // This function is never used
        revert("We don't implement this function.");

        // These statements do nothing, just use to stop compilation warnings
        spender == spender;
        tokens == tokens;
    }

    // ------------------------------------------------------------------------
    // Standard function of ERC token standard #20
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint256 tokens) public pure returns (bool) {
        // This function is never used
        revert("We don't implement this function.");

        // These statements do nothing, just use to stop compilation warnings
        from == from;
        to == to;
        tokens == tokens;
    }
}