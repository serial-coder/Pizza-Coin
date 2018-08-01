/*
* Copyright (c) 2018, Phuwanai Thummavet (serial-coder). All rights reserved.
* Github: https://github.com/serial-coder
* Contact us: mr[dot]thummavet[at]gmail[dot]com
*/

pragma solidity ^0.4.23;

import "./PizzaCoinTeam.sol";


// ----------------------------------------------------------------------------
// Pizza Coin Team Deployer Library
// ----------------------------------------------------------------------------
library PizzaCoinTeamDeployer {

    // ------------------------------------------------------------------------
    // Create a team contract
    // ------------------------------------------------------------------------
    function deployContract() 
        public 
        returns (
            PizzaCoinTeam _teamContract
        ) 
    {
        _teamContract = new PizzaCoinTeam();
    }

    // ------------------------------------------------------------------------
    // Transfer a contract owner to a new one
    // ------------------------------------------------------------------------
    function transferOwnership(address _teamContract, address _newOwner) public {
        require(
            _teamContract != address(0),
            "'_teamContract' contains an invalid address."
        );

        require(
            _newOwner != address(0),
            "'_newOwner' contains an invalid address."
        );

        PizzaCoinTeam(_teamContract).transferOwnership(_newOwner);
    }
}