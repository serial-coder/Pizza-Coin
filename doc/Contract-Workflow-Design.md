## Brief Synopsis of Pizza Hackathon Project

The Pizza Coin (PZC) is a voting system based on Ethereum blockchain's smart contract compatible with ERC-20 token standard which would be used in the 1st Blockchain hackathon event in Thailand on 25-26 August 2018.

Specifically, the PZC is enabling all the event participants (i.e., all the players and the staffs) to selectively give voting tokens to his/her favorite projects developed by his/her other different teams. All the voting results are transacted and recorded on the blockchain. As a result, the winner team which gets a maximum voting tokens would be judged transparently by the developed PZC contract without any possible interference even by any event staff.

## Workflow Design of Pizza Coin Contract

One of the biggest challenges when developing an Ethereum smart contract is the way to handle 'Out-of-Gas' error while deploying the contract to the blockchain network due to the block gas limit on Ethereum blockchain (about 8 million in wei unit). The prototype of our PZC contract also confronted with this limit since our contract requires several functional subsystems such as staff management, team and player management and voting management subsystems. To avoid the block gas limit problem, we decided to develop the PZC contract using the contract factory method (we will describe the details later on).

The PZC contract consists of eight dependencies including Staff contract, Player contract, Team contract, Staff Deployer library, Player Deployer library, Team Deployer library, CodeLib library and CodeLib2 library.

The PZC contract acts as the mother contract of all dependencies. the PZC has three children contracts, namely Staff, Player and Team contracts which would be respectively deployed by the libraries named Staff Deployer, Player Deployer, Team Deployer. Furthermore, the PZC also has another two libraries named CodeLib and CodeLib2 which would be used as the external source code libraries for the PZC mother contract itself.

<p align="center"><img src="Diagrams/PZC contract deployment (transparent).png"></p>
<h3 align="center">Figure 1. deployment of Pizza Coin contract</h3><br />

There are two stages when deploying the PZC contract to the blockchain. At the first stage, the PZC mother contract's dependencies (including Player Deployer, Team Deployer, CodeLib and CodeLib2 libraries) have to seperately deploy to the blockchain. The previously deployed instances would be linked and then injected as dependency objects in order to deploy the PZC mother contract to Ethereum network as shown in Figure 1. 
    
<p align="center"><img src="Diagrams/PZC contract initialization (transparent).png"></p>
<h3 align="center">Figure 2. initialization of Pizza Coin contract</h3><br />

At the second stage, the deployed PZC mother contract has to be initialized by creating its children contracts--including Staff, Player and Team contracts--as shown in Figure 2. At this point, we employ the contract deployer libraries (i.e., Staff Deployer, Player Deployer, Team Deployer) to deploy each corresponding child contract. The resulting children contract instances would be returned to store on the PZC contract.

<p align="center"><img src="Diagrams/PZC contract with its children contracts and libs (transparent).png"></p>
<h3 align="center">Figure 3. Pizza Coin contract acts as a contract coordinator for the Staff, Player and Team contracts</h3><br />

This way, the PZC mother contract would be considered as a contract coordinator or a reverse proxy contract for the Staff, Player and Team contracts. When a user need to interact with any contract function, he/she just makes a call to the PZC mother contract. For example, a user wants to join in some specific team, he/she can achieve this by invoking the registerPlayer() function of the PZC contract. The PZC contract would then interact with its children contracts in order to register the contract calling user as a player to the specified team.

On the prototype of our PZC contract, we faced 'Out-of-Gas' error when deploying the contract because the contract contains too many functions. The way we use to avoid such the error on production is to migrate almost all the logical source code of each function to store on another external libraries (i.e., CodeLib and CodeLib2) instead as shown in Figure 3. 

For example, when a user make a call to the registerPlayer() of the PZC contract (let's call PZC.registerPlayer() for short), the PZC.registerPlayer() will forward the calling information to CodeLib.registerPlayer() in order to process the information on behalf of the PZC contract instead. Note that, the CodeLib.registerPlayer() in question is the mapped function of the PZC.registerPlayer() which is stored on the external CodeLib library. Then, the CodeLib.registerPlayer() will hand over the process to the real worker function Player.registerPlayer(). With this code migration method, we can reduce a gas consumption when deploying the PZC mother contract.
