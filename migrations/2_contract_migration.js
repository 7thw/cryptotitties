var TittyPurchase = artifacts.require("TittyPurchase");
var TittyGame = artifacts.require("CTBoatGame");
var CTAuction = artifacts.require("CTAuction");

module.exports = function(deployer) {

  var tittyContract;

  deployer.deploy(TittyPurchase, '0xA2b3737E984f65bb94ED7ebc96cE9A6e243133dC', '0x0bA6a237d09a420b265ADC0719b7Eb558F1096a3').then(function() {
    tittyContract = TittyPurchase.address;
    return deployer.deploy(TittyGame, '0xAD13B27102a4f7887a34a4B55dbcA84B5D4bD7C0', tittyContract, 1520604000);
  }).then(function() {
    return deployer.deploy(CTAuction, tittyContract);
  });
};