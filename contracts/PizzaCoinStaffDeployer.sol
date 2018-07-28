/*
* Copyright (c) 2018, Phuwanai Thummavet (serial-coder). All rights reserved.
* Github: https://github.com/serial-coder
* Contact us: mr[dot]thummavet[at]gmail[dot]com
*/

pragma solidity ^0.4.23;

import "./PizzaCoinStaff.sol";


// ----------------------------------------------------------------------------
// PizzaCoinStaffDeployer Library
// ----------------------------------------------------------------------------
library PizzaCoinStaffDeployer {

    // ------------------------------------------------------------------------
    // Create a staff contract
    // ------------------------------------------------------------------------
    function deployStaffContract(uint256 _voterInitialTokens) 
        public 
        returns (
            PizzaCoinStaff _staffContract
        ) 
    {
        _staffContract = new PizzaCoinStaff(_voterInitialTokens);
    }

    // ------------------------------------------------------------------------
    // Transfer a contract owner to a new one
    // ------------------------------------------------------------------------
    function transferOwnership(address _staffContract, address _newOwner) public {
        PizzaCoinStaff(_staffContract).transferOwnership(_newOwner);
    }
}