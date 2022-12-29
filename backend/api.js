(async function main() {

  var hapi = require('hapi');
  const hre = require('hardhat')
  const ethers = hre.ethers
  const { BigNumber } = ethers
  console.log(ethers);


  const signers = await ethers.getSigners();
  const [host, alice, bob] = signers
  const Token = await ethers.getContractFactory("Token");
  const token = await Token.deploy();
  await token.deployed();
  await token.mint(alice.address, BigNumber.from(10).pow(18).mul(100));
  console.log(alice.address);


  const Bingo = await ethers.getContractFactory("Bingo");
  const bingo = await Bingo.deploy(token.address);
  await bingo.deployed(token.address);

  await bingo.newGame();
  await bingo.start(1);


  var server = new hapi.Server({ port: 3000, host: 'localhost' });
  server.route({
    method: 'GET',
    path: '/balance/{playerID}',
    handler: async function (request, reply) {
      return await token.balanceOf(signers[parseInt(request.params.playerID)].address);
    }
  });
  server.route({
    method: 'GET',
    path: '/new',
    handler: async function (request, reply) {
      return await bingo.connect(host).newGame();
    }
  });
  server.route({
    method: 'GET',
    path: '/start/{game}',
    handler: async function (request, reply) {
      await bingo.start(request.params.game);
      return 'OK'
    }
  });
  server.route({
    method: 'GET',
    path: '/draw/{game}',
    handler: async function (request, reply) {
      return await bingo.connect(host).draw(request.params.game);
    }
  });
  server.route({
    method: 'GET',
    path: '/join/{game}/{playerID}',
    handler: async function (request, reply) {
      return await bingo
        .connect(signers[parseInt(request.params.playerID)])
        .join(request.params.game)
    }
  });
  server.route({
    method: 'GET',
    path: '/mark/{game}/{playerID}/{arr}',
    handler: async function (request, reply) {
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
      return await bingo
        .connect(signers[parseInt(request.params.playerID)])
        .mark(request.params.game, request.params.arr)
    }
  });
  server.route({
    method: 'GET',
    path: '/board/{game}/{playerID}',
    handler: async function (request, reply) {
      let who = signers[parseInt(request.params.playerID)]
      return await bingo
        .connect(who)
        .board(request.params.game, who.address)
    }
  });
  server.route({
    method: 'GET',
    path: '/claim/{game}/{playerID}',
    handler: async function (request, reply) {
      return await bingo
        .connect(signers[parseInt(request.params.playerID)])
        .claim(request.params.game)
    }
  });
  server.start(function () {
    console.log('Server running at:', server.info.uri);
  });
})()
