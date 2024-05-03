const BDOLAToken = artifacts.require("BDOLAToken");
const DOLA = artifacts.require("DOLA");

module.exports = function (deployer) {
  deployer.deploy(BDOLAToken);
  deployer.deploy(DOLA, BDOLAToken.address);
};
