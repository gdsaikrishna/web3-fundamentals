//SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

contract SimpleStorage{

    uint256 favoriteNumber;

    struct People{
        string name;
        uint256 favoriteNumber;
    }

    //Array of struct objects
    People[] public people;
    //Mapping simliar to Hashmap
    mapping(string => uint256) public nameToFavoriteNumber;

    function store(uint256 _favoriteNumber) public {
        favoriteNumber = _favoriteNumber;
    }

    function retrieve() public view returns(uint256) {
        return favoriteNumber;
    } 

    function addPerson(string memory _name, uint256 _favoriteNumber) public{
        people.push(People(_name, _favoriteNumber));
        nameToFavoriteNumber[_name] = _favoriteNumber;
    }

}