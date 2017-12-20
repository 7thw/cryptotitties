// Specifically request an abstraction for MetaCoin
var TittyPurchase = artifacts.require("TittyPurchase");

contract('TittyPurchase', function(accounts) {
    var titty;
  it("should purchase one titty", function() {
    return TittyPurchase.deployed().then(function(instance) {
      titty = instance;
      return titty.purchaseNew(1, "Titty Two", "female", web3.toWei(1, "ether"), {from: accounts[1], value:web3.toWei(1.10, "ether")});
    }).then(function() {
      return titty.getAmountOfTitties.call();
    }).then(function(value) {
        assert.equal(value, 2, "2 is the right amount of titties");        
    });
  });
  it("should have 2 titties", function() {
    return TittyPurchase.deployed().then(function(instance) {
      titty = instance;
      return titty.purchaseNew(2, "Titty Three", "female", web3.toWei(1, "ether"), {from: accounts[2], value:web3.toWei(1.10, "ether")});
    }).then(function() {
      return titty.getAmountOfTitties.call();
    }).then(function(value) {
        assert.equal(value, 3, "3 is the right amount of titties");        
    });
  });
  it("should have have name Titty Two", function() {
    return TittyPurchase.deployed().then(function(instance) {
      titty = instance;
      return titty.getATitty.call(1);
    }).then(function(results) {
        console.log(results[3]);
        assert.equal(results[1], "Titty Two", "This is not the right name");        
    });
  });
  it("should transfer titty two to Account 3", function() {
    return TittyPurchase.deployed().then(function(instance) {
      titty = instance;
      return titty.purchaseExistent(1, {from: accounts[3], value:web3.toWei(1.10, "ether")});
    }).then(function() {
      return titty.belongsTo.call(accounts[3], 1);
    }).then(function(result) {
        assert.equal(result, true, "It doenst belong to " + accounts[3]);        
    });
  });
});