let BearToken = artifacts.require("./BearToken.sol");

module.exports = function(deployer) {
  // Use deployer to state migration tasks.
  deployer.deploy(BearToken);
};

