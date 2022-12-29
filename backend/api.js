var hapi = require('hapi');
const { BigNumber } = require("ethers");


const Token = await ethers.getContractFactory("Token");
const token = await Token.deploy();
await token.deployed();
await token.mint(alice.address, BigNumber.from(10).pow(18).mul(100));

console.log("Token address:", token.address);


const Bingo = await ethers.getContractFactory("Bingo");
const bingo = await Bingo.deploy(token.address);
await bingo.deployed(token.address);

await bingo.newGame();
await bingo.start(1);


var server = new hapi.Server();
server.connection({ port: 3000 });
server.route({
  method: 'GET',
  path: '/new',
  handler: function (request, reply) {
    await bingo.newGame();
  }
});
server.route({
  method: 'GET',
  path: '/start/{game}',
  handler: function (request, reply) {
    await bingo.start(request.params.game);
  }
});
server.route({
  method: 'GET',
  path: '/draw/{game}',
  handler: function (request, reply) {
    await bingo.connect(host).draw(1);
  }
});
server.route({
  method: 'GET',
  path: '/join/{game}/{who}',
  handler: function (request, reply) {
    await bingo.connect(request.params.who).join(request.params.game)
  }
});
server.route({
  method: 'GET',
  path: '/mark/{game}/{who}/{arr}',
  handler: function (request, reply) {
    const lastDrawn = await bingo.lastDrawn(1);
    // console.log(lastDrawn)
    let index = -1, squares = [];
    do {
      index = board.substring(2, 2*25 + 2).indexOf(lastDrawn.substring(2), index+2)
      if (index != -1 && index%2 == 0 && index != 12) {
        squares.push(index/2)
      }
    } while (-1 < index)

    if(squares.length != 0) {
      console.log(squares)
      await bingo.connect(alice).mark(request.params.game, squares)
      board = await bingo.board(request.params.game, alice.address)
    }
    await bingo.connect(request.params.who).mark(request.params.game, request.params.arr)
  }
});
server.route({
  method: 'GET',
  path: '/claim/{game}/{who}',
  handler: function (request, reply) {
    await bingo.connect(request.params.who).claim(request.params.game)
  }
});
server.start(function () {
  console.log('Server running at:', server.info.uri);
});
