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


var web3 = new Web3('http://localhost:7545');
//var web3 = new Web3('http://localhost:8545');

var PizzaCoin = new web3.eth.Contract(
    PizzaCoinJson.abi,
    PizzaCoinJson.networks[5777].address
    //PizzaCoinJson.networks[4].address
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

    // Initialized contracts
    let [
        staffContractAddr, 
        playerContractAddr, 
        teamContractAddr
    ] = await initContracts(ethAccounts[0]);

    console.log('\nInitializing contracts succeeded...');
    console.log('PizzaCoin address: ' + PizzaCoinJson.networks[5777].address);
    //console.log('PizzaCoin address: ' + PizzaCoinJson.networks[4].address);
    console.log('PizzaCoinStaff address: ' + staffContractAddr);
    console.log('PizzaCoinPlayer address: ' + playerContractAddr);
    console.log('PizzaCoinTeam address: ' + teamContractAddr);

    // Register a staff
    registerStaff(ethAccounts[0], ethAccounts[1], 'bright');
    console.log('\nRegistering a staff succeeded...');

    // Register a staff
    registerStaff(ethAccounts[0], ethAccounts[2], 'bright');
    console.log('\nRegistering a staff succeeded...');

    // Kick a staff
    kickStaff(ethAccounts[0], ethAccounts[2]);
    console.log('\nKicking a staff succeeded...');

    // Register a staff
    registerStaff(ethAccounts[0], ethAccounts[2], 'bright');
    console.log('\nRegistering a staff succeeded...');

    // Create a team
    createTeam(ethAccounts[3], 'serial-coder', 'pizza');
    console.log('\nCreating a new team succeeded...');

    // Register a player
    registerPlayer(ethAccounts[4], 'bright', 'pizza');
    console.log('\nRegistering a player succeeded...');

    // Register a player
    registerPlayer(ethAccounts[5], 'bright', 'pizza');
    console.log('\nRegistering a player succeeded...');

    // Create a team
    createTeam(ethAccounts[6], 'robert', 'pizzaHack');
    console.log('\nCreating a new team succeeded...');

    // Register a player
    registerPlayer(ethAccounts[7], 'bob', 'pizzaHack');
    console.log('\nRegistering a player succeeded...');





    // kick player, team, staff (by staff, project deployer (kick himself too), normal player)
    // vote (by staff, player)
    // call functions above in other different contract states
    // show results, ...
}

async function registerPlayer(playerAddr, playerName, teamName) {
    let err, receipt;

    // Register a player
    [err, receipt] = await callContractFunction(
        PizzaCoin.methods.registerPlayer(playerName, teamName).send({
            from: playerAddr,
            gas: 6500000,
            gasPrice: 10000000000
        })
    );

    if (err) {
        throw new Error(err);
    }
}

async function createTeam(creatorAddr, creatorName, teamName) {
    let err, receipt;

    // Create a new team
    [err, receipt] = await callContractFunction(
        PizzaCoin.methods.createTeam(teamName, creatorName).send({
            from: creatorAddr,
            gas: 6500000,
            gasPrice: 10000000000
        })
    );

    if (err) {
        throw new Error(err);
    }
}

async function registerStaff(registrarAddr, staffAddr, staffName) {
    let err, receipt;

    // Register a staff
    [err, receipt] = await callContractFunction(
        PizzaCoin.methods.registerStaff(staffAddr, staffName).send({
            from: registrarAddr,
            gas: 6500000,
            gasPrice: 10000000000
        })
    );

    if (err) {
        throw new Error(err);
    }
}

async function kickStaff(kickerAddr, staffAddr) {
    let err, receipt;

    // Kick a staff
    [err, receipt] = await callContractFunction(
        PizzaCoin.methods.kickStaff(staffAddr).send({
            from: kickerAddr,
            gas: 6500000,
            gasPrice: 10000000000
        })
    );

    if (err) {
        throw new Error(err);
    }
}

async function initContracts(projectDeployerAddr) {
    let err, receipt;
    let staffContractAddr, playerContractAddr, teamContractAddr;
    let state;

    // Create PizzaCoinStaff contract
    [err, receipt] = await callContractFunction(
        PizzaCoin.methods.createStaffContract().send({
            from: projectDeployerAddr,
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
            from: projectDeployerAddr,
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
            from: projectDeployerAddr,
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
            from: projectDeployerAddr,
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
            from: projectDeployerAddr,
        })
    );

    if (state !== 'Registration') {
        throw new Error("Changing contracts' state failed");
    }

    return [staffContractAddr, playerContractAddr, teamContractAddr];
}