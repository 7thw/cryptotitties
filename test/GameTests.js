var TittyGame = artifacts.require("CTBoatGame");
var TittyPurchase = artifacts.require("TittyPurchase");

contract('TittyGame', function(accounts) {
  var game;
  var watcher;
  var titty;
  it(accounts[1] + " Liked this", function() {
    return TittyGame.deployed().then(function(instance) {
      game = instance;
      return TittyPurchase.deployed();
    }).then(function(tittyInstance) {
        titty = tittyInstance;
       
        
        return titty.purchaseNew(2, "Titty Three", "female", web3.toWei(1, "ether"), {from: accounts[1], value:web3.toWei(1, "ether")});       
    }).then(function(result) {
      return game.doVote(1, 10, {from: accounts[3], value:web3.toWei(0.03, "ether")});
    }).then(function (result) {
       // We can loop through result.logs to see if we triggered the Transfer event.
       console.log(result);
      for (var i = 0; i < result.logs.length; i++) {
        var log = result.logs[i];

        console.log(log);

        if (log.event == "Voted") {
          // We found the event!
          var titty = log.args.titty.toNumber();
          break;
        }
      }
      assert.equal(titty, 1);
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