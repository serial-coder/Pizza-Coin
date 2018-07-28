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
    function deployPlayerContract(uint256 _voterInitialTokens) 
        public 
        returns (
            PizzaCoinPlayer _staffContract
        ) 
    {
        _staffContract = new PizzaCoinPlayer(_voterInitialTokens);
    }

    // ------------------------------------------------------------------------
    // Transfer a contract owner to a new one
    // ------------------------------------------------------------------------
    function transferOwnership(address _staffContract, address _newOwner) public {
        PizzaCoinPlayer(_staffContract).transferOwnership(_newOwner);
    }
}