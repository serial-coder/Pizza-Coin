#!/usr/bin/env node

/*
* Copyright (c) 2018, Phuwanai Thummavet (serial-coder). All rights reserved.
* Github: https://github.com/serial-coder
* Contact us: mr[dot]thummavet[at]gmail[dot]com
*/

'use strict';

// Import libraries
const Web3             = require('web3'),
      HDWalletProvider = require("truffle-hdwallet-provider"),
      contract         = require('truffle-contract'),
      PizzaCoinJson    = require('./build/contracts/PizzaCoin.json'),
      mnemonic         = require('./mnemonic.secret'),
      infuraApi        = require('./infura-api.secret');

const provider = new HDWalletProvider(mnemonic, 'https://rinkeby.infura.io/' + infuraApi, 0);
const web3 = new Web3(provider);

main();

async function main() {
    try {
        const projectDeployerAddr = provider.getAddresses()[0];
        console.log('Project deployer address: ' + projectDeployerAddr);

        // Initial PizzaCoin contract instance
        const contractInstance = await initContractInstance();

        console.log('PizzaCoin address: ' + PizzaCoinJson.networks[4].address);

        let contractState = await contractInstance.getContractState();
        console.log('Contract state: ' + contractState);

        // Create PizzaCoinStaff contract
        console.log('Creating PizzaCoinStaff contract...');
        const staffContractAddr = await contractInstance.createStaffContract({
            from: projectDeployerAddr
        });
        console.log('... succeeded');

        // Create PizzaCoinPlayer contract
        console.log('Creating PizzaCoinPlayer contract...');
        const playerContractAddr = await contractInstance.createPlayerContract({
            from: projectDeployerAddr
        });
        console.log('... succeeded');

        // Create PizzaCoinTeam contract
        console.log('Creating PizzaCoinTeam contract...');
        const teamContractAddr = await contractInstance.createTeamContract({
            from: projectDeployerAddr
        });
        console.log('... succeeded');

        // Change all contracts' state from Initial to Registration
        console.log('Changing a contract state to Registration...');
        await contractInstance.startRegistration({
            from: projectDeployerAddr
        });
        console.log('... succeeded');

        contractState = await contractInstance.getContractState();
        console.log('Contract state: ' + contractState);

        console.log('--------------- All done ---------------');
        console.log('Project deployer address: ' + projectDeployerAddr);
        console.log('PizzaCoin address: ' + PizzaCoinJson.networks[4].address);
        console.log('PizzaCoinStaff address: ' + staffContractAddr.logs[0].args._contract);
        console.log('PizzaCoinPlayer address: ' + playerContractAddr.logs[0].args._contract);
        console.log('PizzaCoinTeam address: ' + teamContractAddr.logs[0].args._contract);

        process.exit(0);
    }
    catch (err) {
        return console.error(err);
    }
}

async function initContractInstance() {

    try {
        const PizzaCoinContract = contract(PizzaCoinJson);
        PizzaCoinContract.setProvider(web3.currentProvider);

        fixTruffleContractCompatibilityIssue(PizzaCoinContract);

        // Calling Async function
        const contractInstance = await PizzaCoinContract.deployed();

        return contractInstance;
    }
    catch (err) {
        console.error('err: ' + err);
    }
}

function fixTruffleContractCompatibilityIssue (contract) {
    /*
        Dirty hack for web3@1.0.0 support for localhost testrpc, 
        see 'https://github.com/trufflesuite/truffle-contract
                /issues/56#issuecomment-331084530'
    */
    if ( typeof contract.currentProvider.sendAsync !== 'function' ) {
        contract.currentProvider.sendAsync = () => {
            return contract.currentProvider.send.apply(
                contract.currentProvider, 
                arguments
            );
        }
    }

    return contract;
}