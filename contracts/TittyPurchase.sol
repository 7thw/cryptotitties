pragma solidity ^0.4.18;

import "./TittyOwnership.sol";

contract TittyPurchase is TittyOwnership {

    address private wallet;
    address private boat;

    function TittyPurchase(address _wallet, address _boat) public {
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
        uint256 fee = calculateFee(titty.salePrice);
        if (msg.value == 0 && msg.value != titty.salePrice)
            revert();
        
        uint256 val = msg.value - fee;
        address owner = tittyIndexToOwner[_tittyId];
        _approve(_tittyId, msg.sender);
        transferFrom(owner, msg.sender, _tittyId);
        owner.transfer(val);
        wallet.transfer(fee);

    }

    function purchaseAccessory(uint256 _tittyId, uint256 _accId, string _name, uint256 _price) public payable {

        if (msg.value == 0 && msg.value != _price)
            revert();

        wallet.transfer(msg.value);
        addAccessory(_accId, _name, _price,  _tittyId);
        
        
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

    function changePrice(uint256 _price, uint256 _tittyId) public {
        _changeTittyPrice(_price, _tittyId);
    }

    function changeName(string _name, uint256 _tittyId) public {
        _changeName(_name, _tittyId);
    }

    function makeItSellable(uint256 _tittyId) public {
        _setTittyForSale(true, _tittyId);
    }

    function calculateFee (uint256 _price) internal pure returns(uint) {
        return (_price * 10)/100;
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
        uint256 originalPrice,
        uint256 salePrice,
        bool forSale
        ) {

            Titty storage titty = Titties[_tittyId];
            id = titty.id;
            name = titty.name;
            gender = titty.gender;
            originalPrice = titty.originalPrice;
            salePrice = titty.salePrice;
            forSale = titty.forSale;
        }

}