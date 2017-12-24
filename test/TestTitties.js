// Specifically request an abstraction for MetaCoin
var TittyTests = artifacts.require("TittyTests");

contract('TittyTests', function(accounts) {
    var titty;
  it("Total ID", function() {
    return TittyTests.deployed().then(function(instance) {
      titty = instance;
      return titty.createTitty();
    }).then(function() {
      return titty.createTitty();
    }).then(function() {
      return titty.totalSupply.call();
    }).then(function(value) {
      console.log(value.toNumber());
      assert.isAbove(value.toNumber(), 0, "Titties should be bigger that 0");        
    })
  });
  
});