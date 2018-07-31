/*
* Copyright (c) 2018, Phuwanai Thummavet (serial-coder). All rights reserved.
* Github: https://github.com/serial-coder
* Contact us: mr[dot]thummavet[at]gmail[dot]com
*/

'use strict';

// Import libraries
var Web3               = require('web3'),
    PizzaCoinJson      = require('../build/contracts/PizzaCoin.json'),
    PizzaCoinStaffJson = require('../build/contracts/PizzaCoinStaff.json');

/*
        let web3 = new Web3.providers.HttpProvider('http://localhost:7545')
    
        The above code works with web3@0.20.2 but it does not work with web3@1.0.0,
        since web3@1.0.0 does no longer support for HttpProvider() anymore
    */
var web3 = new Web3('http://localhost:7545');

setup();
async function setup() {
    let PizzaCoin = new web3.eth.Contract(
        PizzaCoinJson.abi,
        PizzaCoinJson.networks[5777].address
    );

    let ethAccounts = await web3.eth.getAccounts();

    console.log('Sender address: ' + ethAccounts[0]);
    console.log('PizzaCoin address: ' + PizzaCoinJson.networks[5777].address);

    /*// Using the event emitter
    PizzaCoin.methods.createStaffContract().send(
    //PizzaCoin.methods.startRegistration().send(
        {
            from: ethAccounts[0],
            gas: 6500000,
            gasPrice: 10000000000
        }
    )
    .on('transactionHash', function(hash){
        console.log(hash);
    })
    //.on('confirmation', function(confirmationNumber, receipt){
    //    console.log(confirmationNumber);
    //    console.log(receipt);
    //})
    .on('receipt', function(receipt){
        // receipt example
        console.log(receipt);
        console.log(receipt.events.ContractCreated.returnValues);
    })
    .on('error', console.error); // If there's an out of gas error the second parameter is the receipt.*/





    /*// using the promise
    PizzaCoin.methods.getContractState().call(
        {
            from: ethAccounts[0]
        }
    )
    .then(function(receipt){
        // receipt can also be a new contract instance, when coming from a "contract.deploy({...}).send()"
        console.log(receipt);
        //console.log(receipt.events.ContractCreated.returnValues);
    })
    .catch(err => console.error(err));*/





    // using the promise
    PizzaCoin.methods.createStaffContract().send(
        {
            from: ethAccounts[0],
            gas: 6500000,
            gasPrice: 10000000000
        }
    )
    .then(function(receipt){
        // receipt can also be a new contract instance, when coming from a "contract.deploy({...}).send()"
        console.log(receipt);
        console.log(receipt.events.ContractCreated.returnValues);
    })
    .catch(err => console.error(err));




    /*// using the promise
    PizzaCoin.methods.registerStaff(ethAccounts[1], "bright").send(
        {
            from: ethAccounts[0],
            gas: 6500000,
            gasPrice: 10000000000
        }
    )
    .then(function(receipt){
        // receipt can also be a new contract instance, when coming from a "contract.deploy({...}).send()"
        console.log(receipt);
        //console.log(receipt.events.StaffRegistered.returnValues);//.returnValues);
        //console.log(receipt.events.StaffRegistered);//.returnValues);
    })
    .catch(err => console.error(err));*/




    /*let PizzaCoinStaff = new web3.eth.Contract(
        PizzaCoinStaffJson.abi,
        "0x816A402C09B70f3c9e8FBd02b18D4035f91f6C79"
    );

    // using the promise
    PizzaCoinStaff.methods.registerStaff(ethAccounts[1], "bright").send(
        {
            from: ethAccounts[0],
            gas: 6500000,
            gasPrice: 10000000000
        }
    )
    .then(function(receipt){
        // receipt can also be a new contract instance, when coming from a "contract.deploy({...}).send()"
        console.log(receipt);
        console.log(receipt.events.StaffRegistered.returnValues);
    })
    .catch(err => console.error(err));*/



    /*let PizzaCoinStaff = new web3.eth.Contract(
        PizzaCoinStaffJson.abi,
        "0x816A402C09B70f3c9e8FBd02b18D4035f91f6C79"
    );

    // using the promise
    PizzaCoinStaff.methods.getTotalStaffs().call(
        {
            from: ethAccounts[0]
        }
    )
    .then(function(receipt){
        // receipt can also be a new contract instance, when coming from a "contract.deploy({...}).send()"
        console.log(receipt);
        //console.log(receipt.events.ContractCreated.returnValues);
    })
    .catch(err => console.error(err));*/
}