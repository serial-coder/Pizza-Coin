/*
* Copyright (c) 2018, Phuwanai Thummavet (serial-coder). All rights reserved.
* Github: https://github.com/serial-coder
* Contact us: mr[dot]thummavet[at]gmail[dot]com
*/

pragma solidity ^0.4.23;

import "./SafeMath.sol";
//import "./BasicStringUtils.sol";
import "./PizzaCoinStaff.sol";
import "./PizzaCoinPlayer.sol";
import "./PizzaCoinTeam.sol";


// ----------------------------------------------------------------------------
// TestLib2 Library
// ----------------------------------------------------------------------------
library TestLib2 {
    using SafeMath for uint256;
    //using BasicStringUtils for string;


    // ------------------------------------------------------------------------
    // Determine if _user is a staff or not
    // ------------------------------------------------------------------------
    function isStaff(address _user, address _staffContract) public view returns (bool bStaff) {
        require(
            _staffContract != address(0),
            "'_staffContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        IStaffContract staffContractInstance = IStaffContract(_staffContract);

        return staffContractInstance.isStaff(_user);
    }

    // ------------------------------------------------------------------------
    // Determine if _user is a player or not
    // ------------------------------------------------------------------------
    function isPlayer(address _user, address _playerContract) public view returns (bool bPlayer) {
        require(
            _playerContract != address(0),
            "'_playerContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        IPlayerContract playerContractInstance = IPlayerContract(_playerContract);

        return playerContractInstance.isPlayer(_user);
    }

    // ------------------------------------------------------------------------
    // Get a total number of staffs
    // ------------------------------------------------------------------------
    function getTotalStaffs(address _staffContract) public view returns (uint256 _total) {
        require(
            _staffContract != address(0),
            "'_staffContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        IStaffContract staffContractInstance = IStaffContract(_staffContract);

        return staffContractInstance.getTotalStaffs();
    }

    // ------------------------------------------------------------------------
    // Get an info of the first found staff 
    // (start searching at _startSearchingIndex)
    // ------------------------------------------------------------------------
    function getFirstFoundStaffInfo(uint256 _startSearchingIndex, address _staffContract) 
        public view
        returns (
            bool _endOfList, 
            uint256 _nextStartSearchingIndex,
            address _staff,
            string _name,
            uint256 _tokensBalance
        ) 
    {
        require(
            _staffContract != address(0),
            "'_staffContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        IStaffContract staffContractInstance = IStaffContract(_staffContract);

        return staffContractInstance.getFirstFoundStaffInfo(_startSearchingIndex);
    }

    // ------------------------------------------------------------------------
    // Get a total number of the votes ('teamsVoted' array) made by the specified staff
    // ------------------------------------------------------------------------
    function getTotalVotesByStaff(address _staff, address _staffContract) public view returns (uint256 _total) {
        require(
            _staffContract != address(0),
            "'_staffContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        IStaffContract staffContractInstance = IStaffContract(_staffContract);

        return staffContractInstance.getTotalVotesByStaff(_staff);
    }

    // ------------------------------------------------------------------------
    // Get a team voting result (at the index of 'teamsVoted' array) made by the specified staff
    // ------------------------------------------------------------------------
    function getVoteResultAtIndexByStaff(address _staff, uint256 _votingIndex, address _staffContract) 
        public view
        returns (
            bool _endOfList,
            string _team,
            uint256 _voteWeight
        ) 
    {
        require(
            _staffContract != address(0),
            "'_staffContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        IStaffContract staffContractInstance = IStaffContract(_staffContract);

        return staffContractInstance.getVoteResultAtIndexByStaff(_staff, _votingIndex);
    }

    // ------------------------------------------------------------------------
    // Get a total number of players
    // ------------------------------------------------------------------------
    function getTotalPlayers(address _playerContract) public view returns (uint256 _total) {
        require(
            _playerContract != address(0),
            "'_playerContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        IPlayerContract playerContractInstance = IPlayerContract(_playerContract);

        return playerContractInstance.getTotalPlayers();
    }

    // ------------------------------------------------------------------------
    // Get an info of the first found player 
    // (start searching at _startSearchingIndex)
    // ------------------------------------------------------------------------
    function getFirstFoundPlayerInfo(uint256 _startSearchingIndex, address _playerContract) 
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
        require(
            _playerContract != address(0),
            "'_playerContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        IPlayerContract playerContractInstance = IPlayerContract(_playerContract);

        return playerContractInstance.getFirstFoundPlayerInfo(_startSearchingIndex);
    }

    // ------------------------------------------------------------------------
    // Get a total number of the votes ('teamsVoted' array) made by the specified player
    // ------------------------------------------------------------------------
    function getTotalVotesByPlayer(address _player, address _playerContract) public view returns (uint256 _total) {
        require(
            _playerContract != address(0),
            "'_playerContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        IPlayerContract playerContractInstance = IPlayerContract(_playerContract);

        return playerContractInstance.getTotalVotesByPlayer(_player); 
    }

    // ------------------------------------------------------------------------
    // Get a team voting result (at the index of 'teamsVoted' array) made by the specified player
    // ------------------------------------------------------------------------
    function getVoteResultAtIndexByPlayer(address _player, uint256 _votingIndex, address _playerContract) 
        public view
        returns (
            bool _endOfList,
            string _team,
            uint256 _voteWeight
        ) 
    {
        require(
            _playerContract != address(0),
            "'_playerContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        IPlayerContract playerContractInstance = IPlayerContract(_playerContract);

        return playerContractInstance.getVoteResultAtIndexByPlayer(_player, _votingIndex);
    }

    // ------------------------------------------------------------------------
    // Get a total number of teams
    // ------------------------------------------------------------------------
    function getTotalTeams(address _teamContract) public view returns (uint256 _total) {
        require(
            _teamContract != address(0),
            "'_teamContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        ITeamContract teamContractInstance = ITeamContract(_teamContract);

        return teamContractInstance.getTotalTeams();
    }

    // ------------------------------------------------------------------------
    // Get an info of the first found team 
    // (start searching at _startSearchingIndex)
    // ------------------------------------------------------------------------
    function getFirstFoundTeamInfo(uint256 _startSearchingIndex, address _teamContract) 
        public view
        returns (
            bool _endOfList, 
            uint256 _nextStartSearchingIndex,
            string _teamName,
            uint256 _totalVoted
        ) 
    {
        require(
            _teamContract != address(0),
            "'_teamContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        ITeamContract teamContractInstance = ITeamContract(_teamContract);

        return teamContractInstance.getFirstFoundTeamInfo(_startSearchingIndex);
    }

    // ------------------------------------------------------------------------
    // Get a total number of voters to a specified team
    // ------------------------------------------------------------------------
    function getTotalVotersToTeam(string _teamName, address _teamContract) public view returns (uint256 _total) {
        require(
            _teamContract != address(0),
            "'_teamContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        ITeamContract teamContractInstance = ITeamContract(_teamContract);

        return teamContractInstance.getTotalVotersToTeam(_teamName);
    }

    // ------------------------------------------------------------------------
    // Get a voting result (by the index of voters) to a specified team
    // ------------------------------------------------------------------------
    function getVoteResultAtIndexToTeam(string _teamName, uint256 _voterIndex, address _teamContract) 
        public view
        returns (
            bool _endOfList,
            address _voter,
            uint256 _voteWeight
        ) 
    {
        require(
            _teamContract != address(0),
            "'_teamContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        ITeamContract teamContractInstance = ITeamContract(_teamContract);

        return teamContractInstance.getVoteResultAtIndexToTeam(_teamName, _voterIndex);
    }

    // ------------------------------------------------------------------------
    // Get a total number of players in a specified team
    // ------------------------------------------------------------------------
    function getTotalPlayersInTeam(string _teamName, address _teamContract) public view returns (uint256 _total) {
        require(
            _teamContract != address(0),
            "'_teamContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        ITeamContract teamContractInstance = ITeamContract(_teamContract);

        return teamContractInstance.getTotalPlayersInTeam(_teamName);
    }

    // ------------------------------------------------------------------------
    // Get the first found player of a specified team
    // (start searching at _startSearchingIndex)
    // ------------------------------------------------------------------------
    function getFirstFoundPlayerInTeam(string _teamName, uint256 _startSearchingIndex, address _teamContract) 
        public view
        returns (
            bool _endOfList, 
            uint256 _nextStartSearchingIndex,
            address _player
        ) 
    {
        require(
            _teamContract != address(0),
            "'_teamContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        ITeamContract teamContractInstance = ITeamContract(_teamContract);

        return teamContractInstance.getFirstFoundPlayerInTeam(_teamName, _startSearchingIndex);
    }

    // ------------------------------------------------------------------------
    // Find a maximum voting points from each team after voting is finished
    // ------------------------------------------------------------------------
    function getMaxTeamVotingPoints(address _teamContract) public view returns (uint256 _maxTeamVotingPoints) {
        require(
            _teamContract != address(0),
            "'_teamContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        ITeamContract teamContractInstance = ITeamContract(_teamContract);

        return teamContractInstance.getMaxTeamVotingPoints();
    }

    // ------------------------------------------------------------------------
    // Get a total number of team winners after voting is finished
    // It is possible to have several teams that got the equal maximum voting points 
    // ------------------------------------------------------------------------
    function getTotalTeamWinners(address _teamContract) public view returns (uint256 _total) {
        require(
            _teamContract != address(0),
            "'_teamContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        ITeamContract teamContractInstance = ITeamContract(_teamContract);

        return teamContractInstance.getTotalTeamWinners();
    }

    // ------------------------------------------------------------------------
    // Get the first found team winner
    // (start searching at _startSearchingIndex)
    // It is possible to have several teams that got the equal maximum voting points 
    // ------------------------------------------------------------------------
    function getFirstFoundTeamWinner(uint256 _startSearchingIndex, address _teamContract) 
        public view
        returns (
            bool _endOfList,
            uint256 _nextStartSearchingIndex,
            string _teamName, 
            uint256 _totalVoted
        )
    {
        require(
            _teamContract != address(0),
            "'_teamContract' contains an invalid address."
        );

        // Get a contract instance from the deployed addresses
        ITeamContract teamContractInstance = ITeamContract(_teamContract);

        return teamContractInstance.getFirstFoundTeamWinner(_startSearchingIndex);
    }

    // ------------------------------------------------------------------------
    // Transfer the state of child contracts from Registration to RegistrationLocked state
    // ------------------------------------------------------------------------
    function signalChildContractsToLockRegistration(
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

        // Transfer the state of child contracts
        staffContractInstance.lockRegistration();
        playerContractInstance.lockRegistration();
        teamContractInstance.lockRegistration();
    }

    // ------------------------------------------------------------------------
    // Transfer the state of child contracts from RegistrationLocked to Voting state
    // ------------------------------------------------------------------------
    function signalChildContractsToVoting(
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

        // Transfer the state of child contracts
        staffContractInstance.startVoting();
        playerContractInstance.startVoting();
        teamContractInstance.startVoting();
    }

    // ------------------------------------------------------------------------
    // Transfer the state of child contracts from Voting to VotingFinished state
    // ------------------------------------------------------------------------
    function signalChildContractsToStopVoting(
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

        // Transfer the state of child contracts
        staffContractInstance.stopVoting();
        playerContractInstance.stopVoting();
        teamContractInstance.stopVoting();
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