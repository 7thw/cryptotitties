pragma solidity ^0.4.18;

import "./TittyPurchase.sol";

contract CTBoatGame {

    address private wallet;
    address private contractOwner;
    uint endDate;

    uint256 votePrice = 3 finney;

    TittyPurchase public tittyContract;

    struct Vote {
        uint256 totalRaised;
        uint256 votes;
    }

    Vote[] votes;
    mapping (uint256 => uint256) public tittyVotes;

    event Voted(uint voteId, uint titty);
    
    function CTBoatGame(address _wallet, address _tittyPurchaseAddress, uint _endDate) public {
        wallet = _wallet;
        contractOwner = msg.sender;
        endDate = _endDate;
        tittyContract = TittyPurchase(_tittyPurchaseAddress);
        
        
    }

    function doVote (uint256 _tittyId, uint256 _amount) public payable {

        require (now < endDate);
        
        uint256 total = calculatePrice(_amount);
        if (msg.value < 0 || msg.value != total)
            revert();

        uint256 voteId = tittyVotes[_tittyId];
        if (voteId == 0) {
            voteId = _createVote(_tittyId, _amount, total);
            tittyVotes[_tittyId] = voteId;
        } else {
            Vote storage vote = votes[voteId];
            _addVote(vote, voteId, _amount, total);
        }

        Voted(voteId, _tittyId);
        
        address ownerAddress = tittyContract.ownerOf(_tittyId);

        uint256 charityFee = calculateCharityFee(msg.value);
        uint256 ownerFee = calculateOwnerFee(msg.value);
        ownerAddress.transfer(ownerFee);
        wallet.transfer(msg.value - (charityFee + ownerFee));

    }

    function transferToCharity(address _charity) public {
        
        require(msg.sender == contractOwner);
        _charity.transfer(this.balance);

    }

    function calculatePrice(uint256 _amount) internal view returns (uint) {
        return votePrice * _amount;
    }

    function getOwner(uint256 id) public view returns (address owner) {
        owner = tittyContract.ownerOf(id);
    }

    function _createVote (uint256 _tittyId, uint256 _amount, uint256 _value) internal returns (uint) {

        Vote memory newVote = Vote({
            totalRaised: _value,
            votes: _amount
        });

        uint256 voteId = votes.push(newVote) - 1;
        tittyVotes[_tittyId] = voteId;

        return voteId;
    }

    function _addVote (Vote vote, uint256 voteId, uint256 _amount, uint256 _value) internal {

        vote.totalRaised = vote.totalRaised + _value;
        vote.votes = vote.votes + _amount;
        votes[voteId] = vote;

    }

    function getNumberOfVotes (uint256 _tittyId) public view returns (uint256, uint256) {

        uint256 voteId = tittyVotes[_tittyId];
        Vote storage vote = votes[voteId];

        return (vote.votes, vote.totalRaised);

    }

    function calculateCharityFee (uint256 _price) internal pure returns(uint) {
        return (_price * 70)/100;
    }
    
    function calculateOwnerFee (uint256 _price) internal pure returns(uint) {
        return (_price * 25)/100;
    }

    function() external {}


}