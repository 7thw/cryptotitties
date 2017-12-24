pragma solidity ^0.4.18;

import "./TittyOwnership.sol";

contract TittyPurchase is TittyOwnership {

    address private charity;
    address private wallet;
    address private boat;

    function TittyPurchase(address _charity, address _wallet, address _boat) public {
        charity = _charity;
        wallet = _wallet;
        boat = _boat;

        createTitty(0, "unissex", 1000000000, address(0), "genesis");
    }

    function purchaseNew(uint256 _id, string _name, string _gender, uint256 _price) public payable {

        if (msg.value == 0 && msg.value != _price)
            revert();

        uint256 boatFee = calculateBoatFee(msg.value);
        createTitty(_id, _gender, _price, msg.sender, _name);
        wallet.transfer(msg.value - boatFee);
        boat.transfer(boatFee);

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
        wallet.transfer(fee);

    }

    function getAmountOfTitties() public view returns(uint) {
        return Titties.length;
    }

    function getLatestId() public view returns (uint) {
        return Titties.length - 1;
    }

    function getTittyByWpId(address _owner, uint256 _wpId) public view returns (bool own, uint256 tittyId) {
        
        for (uint256 i = 1; i<=totalSupply(); i++) {
            Titty storage titty = Titties[i];
            bool isOwner = _isOwner(_owner, i);
            if (titty.id == _wpId && isOwner) {
                return (true, i);
            }
        }
        
        return (false, 0);
    }

    function belongsTo(address _account, uint256 _tittyId) public view returns (bool) {
        return _isOwner(_account, _tittyId);
    }

    function like(uint256 _tittyId, uint256 _amount) public payable {

        if (msg.value < 0)
            revert();

        uint256 fee = calculateCharityFee(msg.value);
        charity.transfer(fee);
        wallet.transfer(msg.value - fee);
        _likeTitty(_tittyId, _amount);

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

    function calculateCharityFee (uint256 _price) internal pure returns(uint) {
        return (_price * 70)/100;
    }

    function calculateBoatFee (uint256 _price) internal pure returns(uint) {
        return (_price * 25)/100;
    }

    function() external {}

    function getATitty(uint256 _tittyId)
        public 
        view 
        returns (
        uint256 id,
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