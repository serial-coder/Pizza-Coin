var PizzaCoin = artifacts.require("./PizzaCoin.sol");
var PizzaCoinStaffDeployer = artifacts.require("./PizzaCoinStaffDeployer.sol");
var PizzaCoinPlayerDeployer = artifacts.require("./PizzaCoinPlayerDeployer.sol");
var PizzaCoinTeamDeployer = artifacts.require("./PizzaCoinTeamDeployer.sol");

module.exports = function(deployer) {
  deployer.deploy(PizzaCoinStaffDeployer);
  deployer.deploy(PizzaCoinPlayerDeployer);
  deployer.deploy(PizzaCoinTeamDeployer);

  deployer.link(PizzaCoinStaffDeployer, PizzaCoin);
  deployer.link(PizzaCoinPlayerDeployer, PizzaCoin);
  deployer.link(PizzaCoinTeamDeployer, PizzaCoin);

  deployer.deploy(PizzaCoin, "Phuwanai Thummavet", 3);
};