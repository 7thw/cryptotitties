var TittyAuction = artifacts.require("CTAuction");
var TittyPurchase = artifacts.require("TittyPurchase");

contract('TittyAuction', function(accounts) {
  var auction;
  var watcher;
  var titty;
  var auctionId;
  it(accounts[1] + " Create an Auction", function() {
    return TittyAuction.deployed().then(function(instance) {
        auction = instance;
      return TittyPurchase.deployed();
    }).then(function(tittyInstance) {
        titty = tittyInstance;
        return titty.purchaseNew(2, "Titty Three", "female", web3.toWei(1, "ether"), {from: accounts[1], value:web3.toWei(1, "ether")});       
    }).then(function(result) {
      var time = 4;
      return auction.createAuction(time, 1, web3.toWei(0.03, "ether"), {from: accounts[1]});
    }).then(function (result) {
       // We can loop through result.logs to see if we triggered the Transfer event.
       //console.log(result);
      for (var i = 0; i < result.logs.length; i++) {
        var log = result.logs[i];

        //console.log(log);

        if (log.event == "NewAuctionCreated") {
          // We found the event!
          var titty = log.args.titty.toNumber();
          auctionId = log.args.auctionId.toNumber();
          break;
        }
      }
      assert.equal(titty, 1);
    });
  });
  
  it('Send a Bid', function() {
    return auction.bid(auctionId, {from: accounts[3], value:web3.toWei(1, "ether")}).then(function (result) {
       // We can loop through result.logs to see if we triggered the Transfer event.
       //console.log(result);
      for (var i = 0; i < result.logs.length; i++) {
        var log = result.logs[i];

        //console.log(log);

        if (log.event == "HighestBidIncreased") {
          // We found the event!
          var aid = log.args.auction.toNumber();
          break;
        }
      }
      assert.equal(aid, auctionId);
    });
  });

  it('Send failed bid', function() {
      console.log(auctionId);
    return auction.bid(auctionId, {from: accounts[4], value:web3.toWei(0.02, "ether")}).then(function (result) {
        for (var i = 0; i < result.logs.length; i++) {
            var log = result.logs[i];
    
            //console.log(log);
    
            if (log.event == "HighestBidIncreased") {
              // We found the event!
              var aid = log.args.auction.toNumber();
              break;
            }
          }
        assert.equal(aid, auctionId);
    }).catch(function(err) {
        assert('Revert Received');
    });
  });
  
});