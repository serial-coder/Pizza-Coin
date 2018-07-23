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

    modifier notRegistered {
        require(
            staffInfo[msg.sender].wasRegistered == false && 
            playersInfo[msg.sender].wasRegistered == false
        );
        _;
    }

    // ------------------------------------------------------------------------
    // Register staff
    // ------------------------------------------------------------------------
    function registerStaff(string _staffName) public notRegistered returns (bool success) {
        // Register new staff
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





}