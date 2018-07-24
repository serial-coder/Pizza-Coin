pragma solidity ^0.4.23;

import "./SafeMath.sol";

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    /*function totalSupply() public constant returns (uint256);
    function balanceOf(address tokenOwner) public constant returns (uint256 balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public returns (bool success);
    function approve(address spender, uint256 tokens) public returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);*/
}

// ----------------------------------------------------------------------------
// Owned Contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

// ----------------------------------------------------------------------------
// Pizza Coin Contract
// ----------------------------------------------------------------------------
contract PizzaCoin is ERC20Interface, Owned {
    using SafeMath for uint256;

    // Token info
    string public symbol;
    string public name;
    uint8 public decimals;
    //uint256 private _totalSupply;

    struct StaffInfo {
        bool wasRegistered;    // Check if a specific staff is being registered
        string name;
        uint256 tokensBalance; // Amount of tokens left for voting
        string[] teamsVoted;   // Record all the teams voted by this staff
        
        // mapping(team => votes)
        mapping(string => uint256) votesWeight;  // A collection of teams with voting weight approved by this staff
    }

    struct TeamPlayerInfo {
        bool wasRegistered;    // Check if a specific player is being registered
        string name;
        uint256 tokensBalance; // Amount of tokens left for voting
        string teamJoined;     // A team this player associates with
        string[] teamsVoted;   // Record all the teams voted by this player
        
        // mapping(team => votes)
        mapping(string => uint256) votesWeight;  // A collection of teams with voting weight approved by this player
    }

    // Team with players
    struct TeamInfo {
        bool wasCreated;    // Check if the team was created for uniqueness
        address[] players;  // A list of team members (the first list member is the team leader who creates the team)
        address[] voters;   // A list of staff and other teams' members who gave votes to this team

        // mapping(voter => votes)
        mapping(address => uint256) votesWeight;  // A collection of team voting weights from each voter (i.e., staff + other teams' members)
        
        uint256 totalVoted;  // Total voting weight got from voters
    }

    address[] private staff;                                 // The first staff is the contract owner
    mapping(address => StaffInfo) private staffInfo;         // mapping(staff => StaffInfo)

    address[] private players;
    mapping(address => TeamPlayerInfo) private playersInfo;  // mapping(player => TeamPlayerInfo)

    string[] private teams;
    mapping(string => TeamInfo) private teamsInfo;           // mapping(team => TeamInfo)

    uint256 private voterInitialTokens;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor(string _ownerName, uint256 _voterInitialTokens) public {
        symbol = "PZC";
        name = "Pizza Coin";
        decimals = 0;

        voterInitialTokens = _voterInitialTokens;

        // Register an owner as staff
        staff[staff.length] = owner;
        staffInfo[owner] = StaffInfo({
            wasRegistered: true,
            name: _ownerName,
            tokensBalance: _voterInitialTokens,
            teamsVoted: new string[](0)
            /*
                Omit 'votesWeight'
            */
        });
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }

    // ------------------------------------------------------------------------
    // Guarantee that msg.sender might not has been registered before
    // ------------------------------------------------------------------------
    modifier notRegistered {
        require(
            staffInfo[msg.sender].wasRegistered == false && 
            playersInfo[msg.sender].wasRegistered == false,
            "This address was registered already."
        );
        _;
    }

    // ------------------------------------------------------------------------
    // Guarantee that msg.sender must be a staff
    // ------------------------------------------------------------------------
    modifier isStaff {
        require(
            staffInfo[msg.sender].wasRegistered == true,
            "This address is not a staff."
        );
        _;
    }

    // ------------------------------------------------------------------------
    // Register a new staff
    // ------------------------------------------------------------------------
    function registerStaff(string _staffName) public notRegistered returns (bool success) {
        // Register a new staff
        staff[staff.length] = msg.sender;
        staffInfo[owner] = StaffInfo({
            wasRegistered: true,
            name: _staffName,
            tokensBalance: voterInitialTokens,
            teamsVoted: new string[](0)
            /*
                Omit 'votesWeight'
            */
        });

        return true;
    }

    // ------------------------------------------------------------------------
    // Team leader creates a team
    // ------------------------------------------------------------------------
    function createTeam(string _teamName, string _creatorName) public notRegistered returns (bool success) {
        require(
            teamsInfo[_teamName].wasCreated == false,
            "The given team was created already."
        );

        address creator = msg.sender;

        // Create a new team
        teams[teams.length] = _teamName;
        teamsInfo[_teamName] = TeamInfo({
            wasCreated: true,
            players: new address[](0),
            voters: new address[](0),
            totalVoted: 0
            /*
                Omit 'votesWeight'
            */
        });

        teamsInfo[_teamName].players.push(creator);

        // Register a team leader to a team
        players[players.length] = creator;
        playersInfo[creator] = TeamPlayerInfo({
            wasRegistered: true,
            name: _creatorName,
            tokensBalance: voterInitialTokens,
            teamJoined: _teamName,
            teamsVoted: new string[](0)
            /*
                Omit 'votesWeight'
            */
        });

        return true;
    }

    // ------------------------------------------------------------------------
    // Register a team player
    // ------------------------------------------------------------------------
    function registerTeamPlayer(string _playerName, string _teamName) public notRegistered returns (bool success) {
        require(
            teamsInfo[_teamName].wasCreated == true,
            "The given team does not exist."
        );

        address player = msg.sender;

        // Register a new player
        players[players.length] = player;
        playersInfo[player] = TeamPlayerInfo({
            wasRegistered: true,
            name: _playerName,
            tokensBalance: voterInitialTokens,
            teamJoined: _teamName,
            teamsVoted: new string[](0)
            /*
                Omit 'votesWeight'
            */
        });

        // Add a player to a team he/she associates with
        teamsInfo[_teamName].players.push(player);

        return true;
    }

    // ------------------------------------------------------------------------
    // Remove the first found player in a particular team 
    // (start searching the player at _basedSearchingIndex)
    // ------------------------------------------------------------------------
    function kickFirstFoundTeamPlayer(string _teamName, uint256 _startSearchingIndex) 
        public isStaff returns (uint256 _nextStartSearchingIndex, uint256 _totalPlayersRemaining) {

        require(
            teamsInfo[_teamName].wasCreated == true,
            "Cannot find the specified team."
        );

        require(
            _startSearchingIndex < players.length,
            "'_startSearchingIndex' is out of bound."
        );

        _nextStartSearchingIndex = players.length;
        _totalPlayersRemaining = 0;

        for (uint256 i = _startSearchingIndex; i < players.length; i++) {
            if (
                playersInfo[players[i]].wasRegistered == true && 
                keccak256(playersInfo[players[i]].teamJoined) == keccak256(_teamName)
            ) {
                // Remove a specific player
                kickTeamPlayer(players[i], _teamName);

                // Start next searching at the next array element
                _nextStartSearchingIndex = i + 1;
                _totalPlayersRemaining = getTotalTeamPlayers(_teamName);
                break;     
            }
        }
    }

    // ------------------------------------------------------------------------
    // Remove a specific player from a particular team
    // ------------------------------------------------------------------------
    function kickTeamPlayer(address _player, string _teamName) public isStaff returns (bool success) {
        require(
            playersInfo[_player].wasRegistered == true &&
            keccak256(playersInfo[_player].teamJoined) == keccak256(_teamName),
            "Cannot find a certain player in a given team."
        );

        bool found;
        uint playerIndex;

        (found, playerIndex) = getPlayerIndex(_player);
        if (!found) {
            revert("Cannot find a certain player.");
        }

        // Reset an element to 0 but the array length never decrease (beware!!)
        delete players[playerIndex];

        // Remove a certain player from a mapping
        delete playersInfo[_player];

        (found, playerIndex) = getTeamPlayerIndex(_player, _teamName);
        if (!found) {
            revert("Cannot find a certain player in a given team.");
        }

        // Reset an element to 0 but the array length never decrease (beware!!)
        delete teamsInfo[_teamName].players[playerIndex];

        return true;
    }

    // ------------------------------------------------------------------------
    // Get the index of a specific player found in the array 'players'
    // ------------------------------------------------------------------------
    function getPlayerIndex(address _player) internal view returns (bool _found, uint256 _playerIndex) {
        _found = false;
        _playerIndex = 0;

        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == _player) {
                _found = true;
                _playerIndex = i;
                break;
            }
        }
    }

    // ------------------------------------------------------------------------
    // Get the index of a specific player in a certain team 
    // found in the the array 'players' in the mapping 'teamsInfo'
    // ------------------------------------------------------------------------
    function getTeamPlayerIndex(address _player, string _teamName) internal view returns (bool _found, uint256 _playerIndex) {
        _found = false;
        _playerIndex = 0;

        for (uint256 i = 0; i < teamsInfo[_teamName].players.length; i++) {
            if (teamsInfo[_teamName].players[i] == _player) {
                _found = true;
                _playerIndex = i;
                break;
            }
        }
    }

    // ------------------------------------------------------------------------
    // Remove a specific team
    // ------------------------------------------------------------------------
    function kickTeam(string _teamName) public isStaff returns (bool success) {
        require(
            teamsInfo[_teamName].wasCreated == true,
            "Cannot find the specified team."
        );

        uint256 totalPlayers = getTotalTeamPlayers(_teamName);

        // The team can be removed if and only if it has 0 player left
        if (totalPlayers != 0) {
            revert("Team is not empty.");
        }

        bool found;
        uint teamIndex;

        (found, teamIndex) = getTeamIndex(_teamName);
        if (!found) {
            revert("Cannot find a certain team.");
        }

        // Reset an element to 0 but the array length never decrease (beware!!)
        delete teams[teamIndex];

        // Remove a certain team from a mapping
        delete teamsInfo[_teamName];

        return true;
    }

    // ------------------------------------------------------------------------
    // Get a total number of the specific team's players
    // ------------------------------------------------------------------------
    function getTotalTeamPlayers(string _teamName) public view returns (uint256 _total) {
        require(
            teamsInfo[_teamName].wasCreated == true,
            "Cannot find the specified team."
        );

        _total = 0;

        for (uint256 i = 0; i < teamsInfo[_teamName].players.length; i++) {
            // teamsInfo[_teamName].players[i] == address(0) 
            // if the player was removed by kickTeamPlayer()
            if (teamsInfo[_teamName].players[i] != address(0))
                _total++;
        }
    }

    // ------------------------------------------------------------------------
    // Get the index of a specific team found in the array 'teams'
    // ------------------------------------------------------------------------
    function getTeamIndex(string _teamName) internal view returns (bool _found, uint256 _teamIndex) {
        _found = false;
        _teamIndex = 0;

        for (uint256 i = 0; i < teams.length; i++) {
            if (keccak256(teams[i]) == keccak256(_teamName)) {
                _found = true;
                _teamIndex = i;
                break;
            }
        }
    }








    // Utility functions
    /*function isEmptyString(string emptyStringTest) private returns (bool bEmpty) {
        bytes memory tempEmptyStringTest = bytes(emptyStringTest);
        return tempEmptyStringTest.length == 0;
    }*/
}