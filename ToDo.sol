//SPDX-License-Identifier:MIT
pragma solidity ^0.8.4;
contract Todo{

    address owner;

    struct taskcount {
        uint id;
        string title;
        bool completed;
    }

    uint counter;

    mapping(uint => taskcount) counts;


    constructor () {
        owner = msg.sender;
        counter = 0;
    }

    event taskadded (string title, uint id);
    event taskcompleted (bool status, uint id);
    
    modifier onlyOwner {
        require(msg.sender == owner, "Only admin can access this function");
        _;
    }

    function addTask(string memory _title) public {
        counts[counter].title = _title;
        counts[counter].id = counter;
        emit taskadded (_title, counter);
        counter++;
    } 
    
    function totalTasks () view public returns (uint) {
        return counter;
    }
    
    function gettask(uint _id) view public returns(string memory, uint, bool) {
        return (counts[_id].title, counts[_id].id, counts[_id].completed);
    }

    function marktaskcompleted(uint _id) public onlyOwner {
        counts[_id].completed = true;
        emit taskcompleted(true, _id);
    }    
}