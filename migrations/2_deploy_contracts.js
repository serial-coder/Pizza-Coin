var PizzaCoin = artifacts.require("./PizzaCoin.sol");
var PizzaCoinStaffDeployer = artifacts.require("./PizzaCoinStaffDeployer.sol");
var PizzaCoinPlayerDeployer = artifacts.require("./PizzaCoinPlayerDeployer.sol");
var PizzaCoinTeamDeployer = artifacts.require("./PizzaCoinTeamDeployer.sol");
var TestLib = artifacts.require("./TestLib.sol");

/*var PizzaCoinStaff = artifacts.require("./PizzaCoinStaff.sol");
var PizzaCoinPlayer = artifacts.require("./PizzaCoinPlayer.sol");
var PizzaCoinTeam = artifacts.require("./PizzaCoinTeam.sol");*/

module.exports = function(deployer) {
  deployer.deploy(PizzaCoinStaffDeployer);
  deployer.deploy(PizzaCoinPlayerDeployer);
  deployer.deploy(PizzaCoinTeamDeployer);
  deployer.deploy(TestLib);

  /*deployer.link(PizzaCoinStaffDeployer, PizzaCoin);
  deployer.link(PizzaCoinPlayerDeployer, PizzaCoin);
  deployer.link(PizzaCoinTeamDeployer, PizzaCoin);
  deployer.link(TestLib, PizzaCoin);*/

  /*deployer.deploy(PizzaCoinStaff, 3);
  deployer.deploy(PizzaCoinPlayer, 3);
  deployer.deploy(PizzaCoinTeam);*/

  deployer.deploy(PizzaCoin, "Phuwanai Thummavet", 3);
};