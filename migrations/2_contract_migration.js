var TittyPurchase = artifacts.require("TittyPurchase");

module.exports = function(deployer) {
    deployer.deploy(TittyPurchase, '0xA2b3737E984f65bb94ED7ebc96cE9A6e243133dC', '0x0bA6a237d09a420b265ADC0719b7Eb558F1096a3');
  };