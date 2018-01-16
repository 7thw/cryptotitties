pragma solidity ^0.4.18;

import "./ERC721Draft.sol";

contract CTBoatGame {

    address private charity;
    address private wallet;

    uint256 votePrice = 30 finney;

    ERC721 public tittyContract;

    struct Vote {
        uint256 totalRaised;
        uint256 votes;
    }

    Vote[] votes;
    mapping (uint256 => uint256) public tittyVotes;
    
    function CTBoatGame(address _wallet, address _charity) public {
        wallet = _wallet;
        charity = _charity;
    }

    function doVote (uint256 _tittyId, uint256 _amount) public payable {
        
        uint256 total = calculatePrice(_amount);
        if (msg.value < 0 || msg.value != total)
            revert();

        uint256 voteId = tittyVotes[_tittyId];
        if (voteId == 0) {
            tittyVotes[_tittyId] = _createVote(_tittyId, _amount, total);
        } else {
            Vote storage vote = votes[voteId];
            _addVote(vote, voteId, _amount, total);
        }

        uint256 fee = calculateCharityFee(msg.value);
        charity.transfer(fee);
        wallet.transfer(msg.value - fee);

    }

    function calculatePrice(uint256 _amount) internal returns (uint) {
        return votePrice * _amount;
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

    function() external {}


}