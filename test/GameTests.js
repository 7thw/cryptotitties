// Specifically request an abstraction for MetaCoin
var TittyGame = artifacts.require("CTBoatGame");

contract('TittyGame', function(accounts) {
  var game;
  it("Is the correct price", function() {
    return TittyGame.deployed().then(function(instance) {
      game = instance;
      return game.calculatePrice.call(10);
    }).then(function(result) {
        assert.equal(web3.fromWei(result.toNumber(), "ether"), 0.3, "should be 10");        
    });
  });
  it(accounts[1] + " Liked this", function() {
    return TittyGame.deployed().then(function(instance) {
      game = instance;
      return game.doVote(1, 10, {from: accounts[1], value:web3.toWei(0.3, "ether")});
    }).then(function(results) {
      return game.getNumberOfVotes.call(1);
    }).then(function(results) {
        assert.equal(results[0], 10, "should be 10");        
    });
  });
  
});

/* contract('TittyGame', function(accounts) {
  var game;
  it(accounts[1] + " Liked this", function() {
    return TittyGame.deployed().then(function(instance) {
      game = instance;
      return game.doVote(1, 10, {from: accounts[1], value:web3.toWei(0.3, "ether")});
    }).then(function(results) {
      return game.getNumberOfVotes.call(1);
    }).then(function(results) {
        assert.equal(results[0], 10, "should be 10");        
    });
  });
  
}); */