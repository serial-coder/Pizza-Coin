var PizzaCoin = artifacts.require("./PizzaCoin.sol");
var PizzaCoinStaffDeployer = artifacts.require("./PizzaCoinStaffDeployer.sol");
var PizzaCoinPlayerDeployer = artifacts.require("./PizzaCoinPlayerDeployer.sol");

module.exports = function(deployer) {
  deployer.deploy(PizzaCoinStaffDeployer);
  deployer.deploy(PizzaCoinPlayerDeployer);

  deployer.link(PizzaCoinStaffDeployer, PizzaCoin);
  deployer.link(PizzaCoinPlayerDeployer, PizzaCoin);

  deployer.deploy(PizzaCoin, "Bright", 3);
};