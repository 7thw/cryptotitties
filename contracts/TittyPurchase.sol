pragma solidity ^0.4.18;

import "./TittyOwnership.sol";

contract TittyPurchase is TittyOwnership {

    function TittyPurchase() public {
        createTitty(0, "unissex", 1000000000, address(0), "quimera");
    }

    function purchaseNew(uint32 _id, string _name, string _gender, uint256 _price) public payable {

        if (msg.value == 0 && msg.value != _price)
            revert();

        createTitty(_id, _gender, _price, msg.sender, _name);

    }

    function purchaseExistent(uint256 _tittyId) public payable {

        Titty storage titty = Titties[_tittyId];
        uint256 fee = calculateFee(titty.price);
        if (msg.value == 0 && msg.value != titty.price)
            revert();
        
        uint256 val = msg.value - fee;
        address owner = tittyIndexToOwner[_tittyId];
        _approve(_tittyId, msg.sender);
        transferFrom(owner, msg.sender, _tittyId);
        owner.transfer(val);

    }

    function getAmountOfTitties() public view returns(uint) {
        return Titties.length;
    }

    function getLatestId() public view returns (uint) {
        return Titties.length - 1;
    }

    function getTittyByWpId(address _owner, uint32 _wpId) public view returns (bool) {
        
        for (uint256 i = 0; i<totalSupply(); i++) {
            Titty storage titty = Titties[i];
            if (titty.id == _wpId && tittyIndexToOwner[i] == _owner) {
                return true;
            }
        }
        
        return false;
    }

    function belongsTo(address _account, uint256 _tittyId) public view returns (bool) {
        return _isOwner(_account, _tittyId);
    }

    function like(uint256 _tittyId) public {
        _likeTitty(_tittyId);
    }

    function changePrice(uint256 _price, uint256 _tittyId) public {
        _changeTittyPrice(_price, _tittyId);
    }

    function makeItSellable(uint256 _tittyId) public {
        _setTittyForSale(true, _tittyId);
    }

    function calculateFee (uint256 _price) internal pure returns(uint) {
        return (_price * 10)/100;
    }

    function() external {}

    function getATitty(uint256 _tittyId)
        public 
        view 
        returns (
        uint32 id,
        string name,
        string gender,
        uint256 price,
        bool forSale,
        uint256 likes

        ) {

            Titty storage titty = Titties[_tittyId];
            id = titty.id;
            name = titty.name;
            gender = titty.gender;
            price = titty.price;
            forSale = titty.forSale;
            likes = titty.likes;

        }

}