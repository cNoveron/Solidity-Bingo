//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.9;

// We import this library to be able to use console.log
import "hardhat/console.sol";
import "./Token.sol";


// This is the main building block for smart contracts.
contract Bingo {

    modifier onlyHost {
        require(msg.sender == host);
        _;
    }
        address host;

    constructor () {
        host = msg.sender;
        token = new Token();
    }
        Token token;


    function newGame() 
        external
        onlyHost
        returns(uint256 gameId)
    {
        gameId = gameCount += 1;
        gameCreated[gameId] = block.timestamp;
    }
        uint256 gameCount;
        mapping(uint256 => uint256) gameCreated;


    function start(uint256 gameId)
        external
        onlyHost
    {
        require(gameCreated[gameId]+minJoinWaitTime < block.timestamp);
        gameStarted[gameId] = true;
    }
        mapping(uint256 => bool) gameStarted;
        uint256 minJoinWaitTime;

    function setMinJoinWaitTime(uint256 _minutes)
        external
        onlyHost
    {
        minJoinWaitTime = _minutes * 1 minutes;
    }



    function draw(uint256 gameId)
        external
        onlyHost
    {
        require(lastTimeDrawn[gameId]+timeBetweenDraws < block.timestamp);
        bytes32 buffer = blockhash(block.number - 1);
        bytes1 drawn = bytes1(buffer);
        while (drawn == bytes1(0)) {
            drawn = bytes1(buffer);
            buffer = buffer << 8;
        }
        lastDrawn[gameId] = bytes1(buffer);
    }
        mapping(uint256 => bytes1) public lastDrawn;
        mapping(uint256 => uint256) public lastTimeDrawn;
        uint256 timeBetweenDraws;

    function setTimeBetweenDraws(uint256 _minutes)
        external
        onlyHost
    {
        timeBetweenDraws = _minutes * 1 minutes;
    }



    function join(uint256 gameId)
        external
    {
        token.transferFrom(msg.sender, address(this), fee);
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
        uint256 fee;

    function setFee(uint256 _fee)
        external
    {
        fee = _fee;
    }


    function mark(uint256 gameId, uint8[] memory squares)
        external
    {
        bytes32 _board = board[gameId][msg.sender];
        for (uint i = 0; i < squares.length; i++) {
            if(squares[i] != 12) {
                bytes32 _mark = bytes32(lastDrawn[gameId]) >> (squares[i]*8);
                board[gameId][msg.sender] = _board ^ _mark;
            }
        }
    }



    function claim(uint256 gameId)
        external
    {
        bool won = false;

        if (row(gameId)) won = true; else
        if (col(gameId)) won = true;
        
        if(won) {
            gameFinished[gameId] = true;
            token.transfer(msg.sender, token.balanceOf(address(this)));
        }
    }
        mapping(uint256 => bool) public gameFinished;



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
