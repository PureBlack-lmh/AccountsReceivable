const AccountsReceivable = artifacts.require("AccountsReceivable");

module.exports = function (deployer) {
  deployer.deploy(AccountsReceivable,"AccountsReceivable");
};
