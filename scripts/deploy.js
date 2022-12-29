// This is a script for deploying your contracts. You can adapt it to deploy
// yours, or create new ones.

const path = require("path");

async function main() {
  // This is just a convenience check
  if (network.name === "hardhat") {
    console.warn(
      "You are trying to deploy a contract to the Hardhat Network, which" +
        "gets automatically created and destroyed every time. Use the Hardhat" +
        " option '--network localhost'"
    );
  }

  // ethers is available in the global scope
  const [host, alice, bob] = await ethers.getSigners();
  console.log(
    "Deploying the contracts with the account:",
    await host.getAddress()
  );

  console.log("Account balance:", (await host.getBalance()).toString());


  const Token = await ethers.getContractFactory("Token");
  const token = await Token.deploy();
  await token.deployed();

  console.log("Token address:", token.address);


  const Bingo = await ethers.getContractFactory("Bingo");
  const bingo = await Bingo.deploy();
  await bingo.deployed();

  await bingo.newGame();
  await bingo.start(1);

  await bingo.connect(alice).join(1)
  var board = await bingo.board(1, alice.address)
  console.log(`board: ${board}`)
  
  for (let i = 0; i < 1000; i++) {
    await bingo.connect(host).draw(1);
    const lastDrawn = await bingo.lastDrawn(1);
    // console.log(lastDrawn)
    let index = -1, squares = [];
    do {
      index = board.substring(2, 2*25 + 2).indexOf(lastDrawn.substring(2), index+1)
      if (index != -1 && index%2 == 0 && index != 12) {
        squares.push(index/2)
      }
    } while (-1 < index)

    if(squares.length != 0) {
      console.log(squares)
      await bingo.connect(alice).mark(1, squares)
      board = await bingo.board(1, alice.address)
    }
  }
  console.log(board)
  // We also save the contract's artifacts and address in the frontend directory
  //saveFrontendFiles(token);
}


function saveFrontendFiles(token) {
  const fs = require("fs");
  const contractsDir = path.join(__dirname, "..", "frontend", "src", "contracts");

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  fs.writeFileSync(
    path.join(contractsDir, "contract-address.json"),
    JSON.stringify({ Token: token.address }, undefined, 2)
  );

  const TokenArtifact = artifacts.readArtifactSync("Token");

  fs.writeFileSync(
    path.join(contractsDir, "Token.json"),
    JSON.stringify(TokenArtifact, null, 2)
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
