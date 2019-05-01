let CubToken = artifacts.require("./CubToken.sol");

module.exports = function(deployer) {
  // Use deployer to state migration tasks.
  deployer.deploy(CubToken);
};
