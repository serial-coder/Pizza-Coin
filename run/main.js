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
    PizzaCoinTeamJson = require('../build/contracts/PizzaCoinTeam.json'),
    pe = require('parse-error');


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
            return [pe(err), null];
            /*console.log('**********');
            console.log(pe(err));
            console.log('**********');
            [pe(err)];*/
        });
}

async function main() {
    let ethAccounts = await web3.eth.getAccounts();

    console.log('Project deployer address: ' + ethAccounts[0]);

    try {
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
        await registerStaff(ethAccounts[0], ethAccounts[1], 'bright');

        // Register a staff
        await registerStaff(ethAccounts[0], ethAccounts[2], 'bright');

        // Kick a staff
        await kickStaff(ethAccounts[0], ethAccounts[2]);

        // Register a staff
        await registerStaff(ethAccounts[0], ethAccounts[2], 'bright');

        // Create a team
        await createTeam(ethAccounts[3], 'serial-coder', 'pizza');

        // Register a player
        await registerPlayer(ethAccounts[4], 'bright', 'pizza');

        // Register a player
        await registerPlayer(ethAccounts[5], 'bright', 'pizza');

        // Create a team
        await createTeam(ethAccounts[6], 'robert', 'pizzaHack');

        // Register a player
        await registerPlayer(ethAccounts[7], 'bob', 'pizzaHack');

        // Kick a player
        await kickPlayer(ethAccounts[0], ethAccounts[7], 'pizzaHack');





        // Register a staff
        //await registerStaff(ethAccounts[2], ethAccounts[8], 'bright');
    }
    catch (err) {
        return console.error(err);
    }

    // kick player, team, staff (by staff, project deployer (kick himself too), normal player)
    // vote (by staff, player)
    // call functions above in other different contract states
    // show results, ...
}

async function registerPlayer(playerAddr, playerName, teamName) {
    let err, receipt;
    console.log('\nRegistering a player --> "' + playerAddr + '" ...');

    // Register a player
    [err, receipt] = await callContractFunction(
        PizzaCoin.methods.registerPlayer(playerName, teamName).send({
            from: playerAddr,
            gas: 6500000,
            gasPrice: 10000000000
        })
    );

    if (err) {
        throw new Error(err.message);
    }
    console.log('... succeeded');
}

async function kickPlayer(kickerAddr, playerAddr, teamName) {
    let err, receipt;
    console.log('\nKicking a player --> "' + playerAddr + '" ...');

    // Kick a player
    [err, receipt] = await callContractFunction(
        PizzaCoin.methods.kickPlayer(playerAddr, teamName).send({
            from: kickerAddr,
            gas: 6500000,
            gasPrice: 10000000000
        })
    );

    if (err) {
        throw new Error(err.message);
    }
    console.log('... succeeded');
}

async function createTeam(creatorAddr, creatorName, teamName) {
    let err, receipt;
    console.log('\nCreating a new team --> "' + teamName + '" ...');

    // Create a new team
    [err, receipt] = await callContractFunction(
        PizzaCoin.methods.createTeam(teamName, creatorName).send({
            from: creatorAddr,
            gas: 6500000,
            gasPrice: 10000000000
        })
    );

    if (err) {
        throw new Error(err.message);
    }
    console.log('... succeeded');
}

async function registerStaff(registrarAddr, staffAddr, staffName) {
    let err, receipt;
    console.log('\nRegistering a staff --> "' + staffAddr + '" ...');

    // Register a staff
    [err, receipt] = await callContractFunction(
        PizzaCoin.methods.registerStaff(staffAddr, staffName).send({
            from: registrarAddr,
            gas: 6500000,
            gasPrice: 10000000000
        })
    );
    
    if (err) {
        throw new Error(err.message);
    }
    console.log('... succeeded');
}

async function kickStaff(kickerAddr, staffAddr) {
    let err, receipt;
    console.log('\nKicking a staff --> "' + staffAddr + '" ...');

    // Kick a staff
    [err, receipt] = await callContractFunction(
        PizzaCoin.methods.kickStaff(staffAddr).send({
            from: kickerAddr,
            gas: 6500000,
            gasPrice: 10000000000
        })
    );

    if (err) {
        throw new Error(err.message);
    }
    console.log('... succeeded');
}

async function initContracts(projectDeployerAddr) {
    let err, receipt;
    let staffContractAddr, playerContractAddr, teamContractAddr;
    let state;

    // Create PizzaCoinStaff contract
    console.log('\nCreating PizzaCoinStaff contract ...');
    [err, receipt] = await callContractFunction(
        PizzaCoin.methods.createStaffContract().send({
            from: projectDeployerAddr,
            gas: 6500000,
            gasPrice: 10000000000
        })
    );

    if (err) {
        throw new Error(err.message);
    }
    console.log('... succeeded');

    staffContractAddr = receipt.events.ChildContractCreated.returnValues._contract;

    // Create PizzaCoinPlayer contract
    console.log('\nCreating PizzaCoinPlayer contract ...');
    [err, receipt] = await callContractFunction(
        PizzaCoin.methods.createPlayerContract().send({
            from: projectDeployerAddr,
            gas: 6500000,
            gasPrice: 10000000000
        })
    );

    if (err) {
        throw new Error(err.message);
    }
    console.log('... succeeded');

    playerContractAddr = receipt.events.ChildContractCreated.returnValues._contract;

    // Create PizzaCoinTeam contract
    console.log('\nCreating PizzaCoinTeam contract ...');
    [err, receipt] = await callContractFunction(
        PizzaCoin.methods.createTeamContract().send({
            from: projectDeployerAddr,
            gas: 6500000,
            gasPrice: 10000000000
        })
    );

    if (err) {
        throw new Error(err.message);
    }
    console.log('... succeeded');

    teamContractAddr = receipt.events.ChildContractCreated.returnValues._contract;

    // Change all contracts' state from Initial to Registration
    console.log("\nStarting the contracts' registration state ...");
    [err, receipt] = await callContractFunction(
        PizzaCoin.methods.startRegistration().send({
            from: projectDeployerAddr,
            gas: 6500000,
            gasPrice: 10000000000
        })
    );
    console.log('... succeeded');

    if (err) {
        throw new Error(err.message);
    }

    // Check the contracts' state
    console.log("\nValidating the contracts' registration state ...");
    [err, state] = await callContractFunction(
        PizzaCoin.methods.getContractState().call({
            from: projectDeployerAddr,
        })
    );

    if (state !== 'Registration') {
        throw new Error("Changing contracts' state failed");
    }
    console.log('... succeeded');

    return [staffContractAddr, playerContractAddr, teamContractAddr];
}