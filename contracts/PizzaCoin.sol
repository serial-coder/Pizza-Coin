pragma solidity ^0.4.24;

import "./SafeMath.sol";

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint256);
    function balanceOf(address tokenOwner) public constant returns (uint256 balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public returns (bool success);
    function approve(address spender, uint256 tokens) public returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
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

    // Coin info
    string public symbol;
    string public name;
    uint8 public decimals;
    //uint256 private _totalSupply;

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

    string[] private teams;
    mapping(string => TeamInfo) private teamsInfo;     // mapping(team => TeamInfo)


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "PZC";
        name = "Pizza Coin";
        decimals = 0;
        //_totalSupply = 1000000 * 10**uint256(decimals);
        //balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, 0);
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }






}