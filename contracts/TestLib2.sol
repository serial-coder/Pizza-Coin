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
//import "./PizzaCoinTeam.sol";


// ----------------------------------------------------------------------------
// TestLib2 Library
// ----------------------------------------------------------------------------
library TestLib2 {
    using SafeMath for uint256;
    //using BasicStringUtils for string;


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