/*
* Copyright (c) 2018, Phuwanai Thummavet (serial-coder). All rights reserved.
* Github: https://github.com/serial-coder
* Contact us: mr[dot]thummavet[at]gmail[dot]com
*/

pragma solidity ^0.4.23;

import "./PizzaCoinPlayer.sol";


// ----------------------------------------------------------------------------
// PizzaCoinPlayerDeployer Library
// ----------------------------------------------------------------------------
library PizzaCoinPlayerDeployer {

    // ------------------------------------------------------------------------
    // Create a player contract
    // ------------------------------------------------------------------------
    function deployContract(uint256 _voterInitialTokens) 
        public view
        returns (
            PizzaCoinPlayer _playerContract
        ) 
    {
        require(
            _voterInitialTokens > 0,
            "'_voterInitialTokens' must be larger than 0."
        );

        _playerContract = new PizzaCoinPlayer(_voterInitialTokens);
    }

    // ------------------------------------------------------------------------
    // Transfer a contract owner to a new one
    // ------------------------------------------------------------------------
    function transferOwnership(address _playerContract, address _newOwner) public view {
        require(
            _playerContract != address(0),
            "'_playerContract' contains an invalid address."
        );

        require(
            _newOwner != address(0),
            "'_newOwner' contains an invalid address."
        );

        PizzaCoinPlayer(_playerContract).transferOwnership(_newOwner);
    }
}