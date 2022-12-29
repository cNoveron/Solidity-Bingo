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
        lastDrawn[gameId] = bytes1(blockhash(block.number - 1));
    }
        mapping(uint256 => bytes1) public lastDrawn;



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
        mapping (uint256 => mapping(address => bytes32)) public board;



    function mark(uint256 gameId, uint8[] memory squares)
        external
    {
        bytes32 _board = board[gameId][msg.sender];
        for (uint i = 0; i < squares.length; i++) {
            if(squares[i] != 12) {
                // console.logBytes32(bytes32(lastDrawn[gameId])>>8);
                bytes32 _mark = bytes32(lastDrawn[gameId]) >> (squares[i]*8);
                board[gameId][msg.sender] = _board ^ _mark;
                console.logBytes32(board[gameId][msg.sender]);
            }
        }
    }



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
        returns (bool)
    {
        bytes32 _board = board[gameId][msg.sender];

        for (uint i = 0; i < 5; i++) {
            if(i != 2) {
                bytes1 buffer = _board[i*5]
                            ^ _board[i*5+1]
                            ^ _board[i*5+2]
                            ^ _board[i*5+3]
                            ^ _board[i*5+4];
                if (buffer == bytes1(0))
                    return true;
            }
        }
        return false;
    }


    function col(uint256 gameId)
        public
        view 
        returns (bool hasCol)
    {
        hasCol = false;
        bytes32 _board = board[gameId][msg.sender];

        for (uint i = 0; i < 5; i++) {
            if(i != 2) {
                bytes1 buffer = _board[i]
                            ^ _board[5+i]
                            ^ _board[10+i]
                            ^ _board[15+i]
                            ^ _board[20+i];
                if (buffer == bytes1(0))
                    return true;
            }
        }
        return false;
    }
}
