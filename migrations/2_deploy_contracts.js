var PizzaCoin = artifacts.require("./PizzaCoin.sol");

module.exports = function(deployer) {
  deployer.deploy(PizzaCoin, "Bright", 3);
};