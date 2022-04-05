// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.5.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.5.0/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    constructor() ERC20("MyToken", "MTK") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    struct Checkpoint {
        uint32 fromBlock;
        uint amountLocked;
        uint rate;
    }


    //record of votes checkpoint for each account by index
    mapping(address => mapping(uint32 => Checkpoint)) public checkpoint;

    //number of checkpoints for each account
    mapping(address => uint32) public numCheckpoints;
    

    function getAmountLocked() public view returns (uint) {
        uint32 nCheckpoints = numCheckpoints[msg.sender];

        if (nCheckpoints > 1){
            uint total_locked;
            for (uint32 i = nCheckpoints; i > 0; i --) {
                uint bet_amount = checkpoint[msg.sender][nCheckpoints -1].amountLocked;

                total_locked += bet_amount; 
                //logic for the id of the bet
                
            }
            return total_locked;
        }
        else {
            return nCheckpoints > 0 ? checkpoint[msg.sender][nCheckpoints - 1].amountLocked: 0;
        }
    }

    function getRate() public view returns (uint) {
        uint32 nCheckpoints = numCheckpoints[msg.sender];
        return nCheckpoints > 0 ? checkpoint[msg.sender][nCheckpoints - 1].rate: 0;
    }

    function getTimestamp() public view returns(uint32){
        uint32 nCheckpoints = numCheckpoints[msg.sender];
        return nCheckpoints > 0 ? checkpoint[msg.sender][nCheckpoints - 1].fromBlock: 0;        
    }

   function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function updateSnapshotForAddress(address _address, uint _amountLocked, uint _rate) public {
        uint32 blockTimestamp = safe32(block.timestamp, "Error!!!");
        uint32 nCheckpoints = numCheckpoints[_address];
        if (nCheckpoints > 0 && checkpoint[_address][nCheckpoints - 1].fromBlock == blockTimestamp) {
            checkpoint[_address][nCheckpoints - 1].amountLocked = _amountLocked;
            checkpoint[_address][nCheckpoints - 1].rate = _rate;
        }
        else {
            checkpoint[_address][nCheckpoints] = Checkpoint(blockTimestamp, _amountLocked, _rate);
            numCheckpoints[_address] = nCheckpoints + 1;
        }
    }
}
