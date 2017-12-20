pragma solidity ^0.4.18;

import "./ERC721Draft.sol";
import "./TittyBase.sol";

contract TittyOwnership is TittyBase, ERC721 {

    string public name = "CryptoTittes";
    string public symbol = "CT";

    function implementsERC721() public pure returns (bool) {
        return true;
    }

    function _isOwner(address _user, uint256 _tittyId) internal view returns (bool) {
        return tittyIndexToOwner[_tittyId] == _user;
    }

    function _approve(uint256 _tittyId, address _approved) internal {
         tittyApproveIndex[_tittyId] = _approved; 
    }

    function _approveFor(address _user, uint256 _tittyId) internal view returns (bool) {
         return tittyApproveIndex[_tittyId] == _user; 
    }

    function totalSupply() public view returns (uint256 total) {
        return Titties.length - 1;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return ownerTittiesCount[_owner];
    }
    
    function ownerOf(uint256 _tokenId) public view returns (address owner) {
        owner = tittyIndexToOwner[_tokenId];
        require(owner != address(0));
    }

    function approve(address _to, uint256 _tokenId) public {
        require(_isOwner(msg.sender, _tokenId));
        _approve(_tokenId, _to);
        Approval(msg.sender, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public {
        require(_approveFor(msg.sender, _tokenId));
        require(_isOwner(_from, _tokenId));

        _transfer(_from, _to, _tokenId);
        

    }
    function transfer(address _to, uint256 _tokenId) public {
        require(_to != address(0));
        require(_isOwner(msg.sender, _tokenId));

        _transfer(msg.sender, _to, _tokenId);
    }



}