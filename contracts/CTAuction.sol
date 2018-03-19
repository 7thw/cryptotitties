pragma solidity ^0.4.18;

import "./TittyPurchase.sol";

contract CTAuction {

    struct Auction {
        // Parameters of the auction. Times are either
        // absolute unix timestamps (seconds since 1970-01-01)
        // or time periods in seconds.
        uint auctionEnd;

        // Current state of the auction.
        address highestBidder;
        uint highestBid;

        //Minumin Bid Set by the beneficiary
        uint minimumBid;

        // Set to true at the end, disallows any change
        bool ended;

        //Titty being Auctioned
        uint titty;

        //Beneficiary
        address beneficiary;
    }

    Auction[] Auctions;

    address public owner; 
    address public ctWallet; 

    // Allowed withdrawals of previous bids
    mapping(address => uint) pendingReturns;

    // CriptoTitty Contract
    TittyPurchase public tittyContract;

    // Events that will be fired on changes.
    event HighestBidIncreased(uint auction, address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);
    event AuctionCancel(uint auction);
    event NewAuctionCreated(uint auctionId, uint titty);

    // The following is a so-called natspec comment,
    // recognizable by the three slashes.
    // It will be shown when the user is asked to
    // confirm a transaction.

    /// Create a simple auction with `_biddingTime`
    /// seconds bidding time on behalf of the
    /// beneficiary address `_beneficiary`.
    function CTAuction(
        address _tittyPurchaseAddress,
        address _wallet
    ) public 
    {
        tittyContract = TittyPurchase(_tittyPurchaseAddress);
        ctWallet = _wallet;
        owner = msg.sender; 
    }

    function createAuction(uint _biddingTime, uint _titty, uint _minimumBid) public {

        address ownerAddress = tittyContract.ownerOf(_titty);
        require(msg.sender == ownerAddress);

        Auction memory auction = Auction({
            auctionEnd: now + _biddingTime,
            titty: _titty,
            beneficiary: msg.sender,
            highestBidder: 0,
            highestBid: 0,
            ended: false,
            minimumBid: _minimumBid
        });

        uint auctionId = Auctions.push(auction) - 1;
        NewAuctionCreated(auctionId, _titty);
    }

    /// Bid on an auction with the value sent
    /// together with this transaction.
    /// The value will only be refunded if the
    /// auction is not won.
    function bid(uint _auction) public payable {

        Auction storage auction = Auctions[_auction];

        // Revert the call if the bidding
        // period is over.
        require(now <= auction.auctionEnd);

        // Revert the call value is less than the minimumBid.
        require(msg.value >= auction.minimumBid);

        // If the bid is not higher, send the
        // money back.
        require(msg.value > auction.highestBid);

        if (auction.highestBid != 0) {
            // Sending back the money by simply using
            // highestBidder.send(highestBid) is a security risk
            // because it could execute an untrusted contract.
            // It is always safer to let the recipients
            // withdraw their money themselves.
            pendingReturns[auction.highestBidder] += auction.highestBid;
        }
        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;
        Auctions[_auction] = auction;
        HighestBidIncreased(_auction, msg.sender, msg.value);
    }

    /// Withdraw a bid that was overbid.
    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        require(amount > 0);
        // It is important to set this to zero because the recipient
        // can call this function again as part of the receiving call
        // before `send` returns.
        pendingReturns[msg.sender] = 0;

        if (!msg.sender.send(amount)) {
            // No need to call throw here, just reset the amount owing
            pendingReturns[msg.sender] = amount;
            return false;
        }
        
        return true;
    }

    function auctionCancel(uint _auction) public {

        Auction storage auction = Auctions[_auction];

        //has to be the beneficiary
        require(msg.sender == auction.beneficiary);

        //Auction Ended
        require(now <= auction.auctionEnd);

        //has no maxbid 
        require(auction.highestBid == 0);

        auction.ended = true;
        Auctions[_auction] = auction;
        AuctionCancel(_auction);

    }

    /// End the auction and send the highest bid
    /// to the beneficiary and 10% to CT.
    function auctionEnd(uint _auction) public {

        // Just cryptotitties CEO can end the auction
        require (owner == msg.sender);

        Auction storage auction = Auctions[_auction];

        require(now <= auction.auctionEnd); // auction has ended
        require(!auction.ended); // this function has already been called

        // End Auction
        auction.ended = true;
        Auctions[_auction] = auction;
        AuctionEnded(auction.highestBidder, auction.highestBid);

        // Send the Funds
        tittyContract.transferFrom(auction.beneficiary, auction.highestBidder, auction.titty);
        uint fee = calculateFee(auction.highestBid);
        ctWallet.transfer(fee);
        auction.beneficiary.transfer(auction.highestBid-fee);

    }

    function calculateFee (uint256 _price) internal pure returns(uint) {
        return (_price * 10)/100;
    }
}