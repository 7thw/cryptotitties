pragma solidity ^0.4.18;

import "./TittyOwnership.sol";

contract TittyTests is TittyOwnership {

    function TittyTests() public {

    }
 
    function createTitty() public returns (uint) {
        return createTitty(0, "unissex", 1000000000, address(0), "genesis");
    }

}