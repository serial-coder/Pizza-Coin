/*
* Copyright (c) 2018, Phuwanai Thummavet (serial-coder). All rights reserved.
* Github: https://github.com/serial-coder
* Contact us: mr[dot]thummavet[at]gmail[dot]com
*/

'use strict';

// Import libraries
var Web3               = require('web3'),
    PizzaCoinJson      = require('../build/contracts/PizzaCoin.json'),
    PizzaCoinStaffJson = require('../build/contracts/PizzaCoinStaff.json'),
    PizzaCoinPlayerJson = require('../build/contracts/PizzaCoinPlayer.json'),
    PizzaCoinTeamJson = require('../build/contracts/PizzaCoinTeam.json');

/*
        let web3 = new Web3.providers.HttpProvider('http://localhost:7545')
    
        The above code works with web3@0.20.2 but it does not work with web3@1.0.0,
        since web3@1.0.0 does no longer support for HttpProvider() anymore
    */
var web3 = new Web3('http://localhost:7545');

var PizzaCoin = new web3.eth.Contract(
    PizzaCoinJson.abi,
    PizzaCoinJson.networks[5777].address
);

main();

function callContractFunction(contractFunction) {
    return contractFunction
        .then(receipt => {
            return [null, receipt];
        })
        .catch(err => {
            return [err, null];
        });
}

async function main() {
    let ethAccounts = await web3.eth.getAccounts();

    console.log('Project deployer address: ' + ethAccounts[0]);
    //console.log('PizzaCoin address: ' + PizzaCoinJson.networks[5777].address);

    // Initialized contracts
    let [
        staffContractAddr, 
        playerContractAddr, 
        teamContractAddr
    ] = await initContracts(ethAccounts);

    console.log('\nInitializing contracts succeeded...');
    console.log('PizzaCoin address: ' + PizzaCoinJson.networks[5777].address);
    console.log('PizzaCoinStaff address: ' + staffContractAddr);
    console.log('PizzaCoinPlayer address: ' + playerContractAddr);
    console.log('PizzaCoinTeam address: ' + teamContractAddr);

    // Register a staff
    registerStaff(ethAccounts, ethAccounts[1], 'bright');
    console.log('\nRegistering a staff succeeded...');
}

async function registerStaff(ethAccounts, staffAddr, staffName) {
    let err, receipt;
    let staffAddrRet, staffNameRet;

    // Register a staff
    [err, receipt] = await callContractFunction(
        PizzaCoin.methods.registerStaff(staffAddr, staffName).send({
            from: ethAccounts[0],
            gas: 6500000,
            gasPrice: 10000000000
        })
    );

    if (err) {
        throw new Error(err);
    }

    staffAddrRet = receipt.events.StaffRegistered.returnValues._staff;
    staffNameRet = receipt.events.StaffRegistered.returnValues._staffName;

    if (staffAddr !== staffAddrRet || staffName !== staffNameRet) {
        throw new Error("Registering a staff failed");
    }
}

async function initContracts(ethAccounts) {
    let err, receipt;
    let staffContractAddr, playerContractAddr, teamContractAddr;
    let state;

    // Create PizzaCoinStaff contract
    [err, receipt] = await callContractFunction(
        PizzaCoin.methods.createStaffContract().send({
            from: ethAccounts[0],
            gas: 6500000,
            gasPrice: 10000000000
        })
    );

    if (err) {
        throw new Error(err);
    }

    staffContractAddr = receipt.events.ChildContractCreated.returnValues._contract;

    // Create PizzaCoinPlayer contract
    [err, receipt] = await callContractFunction(
        PizzaCoin.methods.createPlayerContract().send({
            from: ethAccounts[0],
            gas: 6500000,
            gasPrice: 10000000000
        })
    );

    if (err) {
        throw new Error(err);
    }

    playerContractAddr = receipt.events.ChildContractCreated.returnValues._contract;

    // Create PizzaCoinTeam contract
    [err, receipt] = await callContractFunction(
        PizzaCoin.methods.createTeamContract().send({
            from: ethAccounts[0],
            gas: 6500000,
            gasPrice: 10000000000
        })
    );

    if (err) {
        throw new Error(err);
    }

    teamContractAddr = receipt.events.ChildContractCreated.returnValues._contract;

    // Change all contracts' state from Initial to Registration
    [err, receipt] = await callContractFunction(
        PizzaCoin.methods.startRegistration().send({
            from: ethAccounts[0],
            gas: 6500000,
            gasPrice: 10000000000
        })
    );

    if (err) {
        throw new Error(err);
    }

    // Check the contracts' state
    [err, state] = await callContractFunction(
        PizzaCoin.methods.getContractState().call({
            from: ethAccounts[0],
        })
    );

    if (state !== 'Registration') {
        throw new Error("Changing contracts' state failed");
    }

    return [staffContractAddr, playerContractAddr, teamContractAddr];
}