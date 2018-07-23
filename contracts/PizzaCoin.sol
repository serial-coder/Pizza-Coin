pragma solidity ^0.4.24;

import "./SafeMath.sol";

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
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
contract PizzaCoin {
    using SafeMath for uint256;

    // Staff + Players
    struct VoterInfo {
        bool wasRegistered;   // Check if a specific voter is being registered
        bool isStaff;         // Define that this voter is either a staff or a player
        string name;
        uint256 tokenBalance; // Amount of tokens left for voting
        string teamJoined;    // This var is used only if this voter is a player (i.e., isStaff == false)
        string[] teamsVoted;  // Record all the teams voted by this voter
        
        // mapping(team => votes)
        mapping(string => uint256) votesWeight;  // A collection of voting weights to each team by this voter
    }

    // Team of Players
    struct TeamInfo {
        bool wasCreated;    // Check if the team was created for uniqueness
        address[] players;  // A list of team members (the first list member is the team leader)
        address[] voters;   // A list of other teams' members who gave votes to this team

        // mapping(voter => votes)
        mapping(address => uint256) votesWeight;  // A collection of team voting weights from each voter
        
        uint256 totalVoted;  // Total voting weight got from voters
    }

    address[] private voters;  // Staff + Players
    mapping(address => VoterInfo) private votersInfo;  // mapping(voter => VoterInfo)

    string[] teams;
    mapping(string => TeamInfo) private teamsInfo;     // mapping(team => TeamInfo)

    /*uint256 totalTokensSupply;
    uint256 tokensUsed;*/






}