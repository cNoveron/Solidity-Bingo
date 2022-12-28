//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.9;

// We import this library to be able to use console.log
import "hardhat/console.sol";


// This is the main building block for smart contracts.
contract Bingo {



    function newGame() 
        external
        returns(uint256 gameId)
    {
        gameId = gameCount += 1;
    }
        uint256 gameCount;



    function start(uint256 gameId)
        external
    {
        gameStarted[gameId] = true;
    }
        mapping(uint256 => bool) gameStarted;



    function draw(uint256 gameId)
        external
    {
        lastDrawn[gameId] = uint(blockhash(block.number - 1));
    }
        mapping(uint256 => uint256) lastDrawn;



    function join(uint256 gameId)  
        external
    {
        /* pay fee */
        joined[gameId][msg.sender] = true;
        board[gameId][msg.sender] = keccak256(abi.encode(
            block.number,
            block.timestamp,
            block.basefee,
            block.coinbase,
            msg.sender, 
            gameId
        ));
    }
        mapping (uint256 => mapping(address => bool)) joined;
        mapping (uint256 => mapping(address => bytes32)) board;



    function mark(uint256 gameId, uint8[] memory squares)
        external
    {
        for (uint i = 0; i < squares.length; i++) {
            if(squares[i] != 12)
                marks[gameId][msg.sender][squares[i]] = true;   
        }
    }
        mapping (uint256 => mapping(address => bool[25])) marks;


    function claim(uint256 gameId)
        external
    {
        if (row(gameId)) gameFinished[gameId] = true;
        if (col(gameId)) gameFinished[gameId] = true;
        // TO-DO : Deposit token prize
    }
        mapping(uint256 => bool) gameFinished;



    function row(uint256 gameId)
        public
        view 
        returns (bool hasRow)
    {
        hasRow = false;
        for (uint i = 0; i < 5; i++) {
            if(i != 2)
                hasRow = marks[gameId][msg.sender][i*5]
                        && marks[gameId][msg.sender][i*5+1]
                        && marks[gameId][msg.sender][i*5+2]
                        && marks[gameId][msg.sender][i*5+3]
                        && marks[gameId][msg.sender][i*5+4];
        }
    }


    function col(uint256 gameId)
        public
        view 
        returns (bool hasCol)
    {
        hasCol = false;
        for (uint i = 0; i < 5; i++) {
            if(i != 2)
                hasCol = marks[gameId][msg.sender][0+i]
                        && marks[gameId][msg.sender][5+i]
                        && marks[gameId][msg.sender][15+i]
                        && marks[gameId][msg.sender][20+i]
                        && marks[gameId][msg.sender][25+i];
        }
    }
}
