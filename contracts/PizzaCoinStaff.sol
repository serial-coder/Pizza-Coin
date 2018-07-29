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
// Interface for exporting public and external functions of PizzaCoinStaff contract
// ------------------------------------------------------------------------
interface IStaffContract {
    function isStaff(address _user) public view returns (bool bStaff);
    function getStaffName(address _staff) public view returns (string _name);
    function registerStaff(address _staff, string _staffName) public;
    function kickStaff(address _staff) public;
    function getTotalStaffs() public view returns (uint256 _total);
    function getFirstFoundStaffInfo(uint256 _startSearchingIndex) 
        public view
        returns (
            bool _endOfList, 
            uint256 _nextStartSearchingIndex,
            address _staff,
            string _name,
            uint256 _tokensBalance
        );
    function getTotalVotesByStaff(address _staff) public view returns (uint256 _total);
    function getVoteResultAtIndexByStaff(address _staff, uint256 _votingIndex) 
        public view
        returns (
            bool _endOfList,
            string _team,
            uint256 _voteWeight
        );
}


// ----------------------------------------------------------------------------
// Pizza Coin Staff Contract
// ----------------------------------------------------------------------------
contract PizzaCoinStaff is IStaffContract, Owned {
    /*
    * Owner of the contract is PizzaCoin contract, 
    * not a project deployer (or PizzaCoin's owner)
    *
    * Let staffs[0] denote a project deployer (i.e., PizzaCoin's owner)
    */

    using SafeMath for uint256;
    using BasicStringUtils for string;

    struct StaffInfo {
        bool wasRegistered;    // Check if a specific staff is being registered
        string name;
        uint256 tokensBalance; // Amount of tokens left for voting
        string[] teamsVoted;   // Record all the teams voted by this staff
        
        // mapping(team => votes)
        mapping(string => uint256) votesWeight;  // A collection of teams with voting weight approved by this staff
    }

    address[] private staffs;                          // The first staff is the contract owner
    mapping(address => StaffInfo) private staffsInfo;  // mapping(staff => StaffInfo)

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
    // Guarantee that msg.sender must be a staff
    // ------------------------------------------------------------------------
    modifier onlyStaff {
        require(
            staffsInfo[msg.sender].wasRegistered == true || msg.sender == owner,
            "This address is not a staff."
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
    // Determine if _user is a project deployer (i.e., PizzaCoin's owner) or not
    // ------------------------------------------------------------------------
    function isProjectDeployer(address _user) internal view onlyPizzaCoin returns (bool bDeployer) {
        /*
        * Owner of the contract is PizzaCoin contract, 
        * not a project deployer (or PizzaCoin's owner)
        *
        * Let staffs[0] denote a project deployer (i.e., PizzaCoin's owner)
        */

        assert(_user != address(0));

        address deployer = staffs[0];
        return deployer == _user && staffsInfo[deployer].wasRegistered == true;
    }

    // ------------------------------------------------------------------------
    // Determine if _user is a staff or not
    // ------------------------------------------------------------------------
    function isStaff(address _user) public view onlyPizzaCoin returns (bool bStaff) {
        require(
            _user != address(0),
            "'_user' contains an invalid address."
        );

        return staffsInfo[_user].wasRegistered;
    }

    // ------------------------------------------------------------------------
    // Get a staff name
    // ------------------------------------------------------------------------
    function getStaffName(address _staff) public view onlyPizzaCoin returns (string _name) {
        require(
            _staff != address(0),
            "'_staff' contains an invalid address."
        );

        require(
            isStaff(_staff) == true,
            "Cannot find the specified staff."
        );

        return staffsInfo[_staff].name;
    }

    // ------------------------------------------------------------------------
    // Register a new staff
    // ------------------------------------------------------------------------
    function registerStaff(address _staff, string _staffName) public onlyRegistrationState onlyPizzaCoin {
        require(
            _staff != address(0),
            "'_staff' contains an invalid address."
        );

        require(
            _staffName.isEmpty() == false,
            "'_staffName' might not be empty."
        );

        require(
            staffsInfo[_staff].wasRegistered == false,
            "The specified staff was registered already."
        );

        // Register a new staff
        staffs.push(_staff);
        staffsInfo[owner] = StaffInfo({
            wasRegistered: true,
            name: _staffName,
            tokensBalance: voterInitialTokens,
            teamsVoted: new string[](0)
            /*
                Omit 'votesWeight'
            */
        });

        _totalSupply = _totalSupply.add(voterInitialTokens);
    }

    // ------------------------------------------------------------------------
    // Remove a specific staff
    // ------------------------------------------------------------------------
    function kickStaff(address _staff) public onlyRegistrationState onlyPizzaCoin {
        require(
            _staff != address(0),
            "'_staff' contains an invalid address."
        );

        require(
            staffsInfo[_staff].wasRegistered == true,
            "Cannot find the specified staff."
        );

        require(
            isProjectDeployer(_staff) == false,
            "Project deployer is not kickable."
        );

        bool found;
        uint staffIndex;

        (found, staffIndex) = getStaffIndex(_staff);
        if (!found) {
            revert("Cannot find the specified staff.");
        }

        // Reset an element to 0 but the array length never decrease (beware!!)
        delete staffs[staffIndex];

        // Remove a specified staff from a mapping
        delete staffsInfo[_staff];

        _totalSupply = _totalSupply.sub(voterInitialTokens);
    }

    // ------------------------------------------------------------------------
    // Get the index of a specific staff found in the array 'staffs'
    // ------------------------------------------------------------------------
    function getStaffIndex(address _staff) internal view onlyPizzaCoin returns (bool _found, uint256 _staffIndex) {
        assert(_staff != address(0));

        _found = false;
        _staffIndex = 0;

        for (uint256 i = 0; i < staffs.length; i++) {
            if (staffs[i] == _staff) {
                _found = true;
                _staffIndex = i;
                return;
            }
        }
    }

    // ------------------------------------------------------------------------
    // Get a total number of staffs
    // ------------------------------------------------------------------------
    function getTotalStaffs() public view onlyPizzaCoin returns (uint256 _total) {
        _total = 0;
        for (uint256 i = 0; i < staffs.length; i++) {
            // Staff was not removed before
            if (staffs[i] != address(0) && staffsInfo[staffs[i]].wasRegistered == true) {
                _total++;
            }
        }
    }

    // ------------------------------------------------------------------------
    // Get an info of the first found staff 
    // (start searching at _startSearchingIndex)
    // ------------------------------------------------------------------------
    function getFirstFoundStaffInfo(uint256 _startSearchingIndex) 
        public view onlyPizzaCoin
        returns (
            bool _endOfList, 
            uint256 _nextStartSearchingIndex,
            address _staff,
            string _name,
            uint256 _tokensBalance
        ) 
    {
        _endOfList = true;
        _nextStartSearchingIndex = staffs.length;
        _staff = address(0);
        _name = "";
        _tokensBalance = 0;

        if (_startSearchingIndex >= staffs.length) {
            return;
        }

        for (uint256 i = _startSearchingIndex; i < staffs.length; i++) {
            address staff = staffs[i];

            // Staff was not removed before
            if (staff != address(0) && staffsInfo[staff].wasRegistered == true) {
                _endOfList = false;
                _nextStartSearchingIndex = i + 1;
                _staff = staff;
                _name = staffsInfo[staff].name;
                _tokensBalance = staffsInfo[staff].tokensBalance;
                return;
            }
        }
    }

    // ------------------------------------------------------------------------
    // Get a total number of the votes ('teamsVoted' array) made by the specified staff
    // ------------------------------------------------------------------------
    function getTotalVotesByStaff(address _staff) public view onlyPizzaCoin returns (uint256 _total) {
        require(
            _staff != address(0),
            "'_staff' contains an invalid address."
        );

        require(
            staffsInfo[_staff].wasRegistered == true,
            "Cannot find the specified staff."
        );

        return staffsInfo[_staff].teamsVoted.length;
    }

    // ------------------------------------------------------------------------
    // Get a team voting result (at the index of 'teamsVoted' array) made by the specified staff
    // ------------------------------------------------------------------------
    function getVoteResultAtIndexByStaff(address _staff, uint256 _votingIndex) 
        public view onlyPizzaCoin
        returns (
            bool _endOfList,
            string _team,
            uint256 _voteWeight
        ) 
    {
        require(
            _staff != address(0),
            "'_staff' contains an invalid address."
        );

        require(
            staffsInfo[_staff].wasRegistered == true,
            "Cannot find the specified staff."
        );

        if (_votingIndex >= staffsInfo[_staff].teamsVoted.length) {
            _endOfList = true;
            _team = "";
            _voteWeight = 0;
            return;
        }

        _endOfList = false;
        _team = staffsInfo[_staff].teamsVoted[_votingIndex];
        _voteWeight = staffsInfo[_staff].votesWeight[_team];
    }
}