const hre = require("hardhat");

async function main() {

  const master = process.env.MASTER;
  const reserve = process.env.RESERVE;

  const CCC = await hre.ethers.getContractFactory("CarbonCreditCoins");

  const contract = await CCC.deploy(
    master,
    reserve,
    "https://ipfs.io/ipfs/QmNxn9RoZRwt9DuQkjw1je9kknVdUPHWWNDDQbEpG7tSmo"
  );

  await contract.waitForDeployment();

  const address = await contract.getAddress();

  console.log("CCC DEPLOYADO EM:", address);

  // salva automaticamente
  const fs = require("fs");
  fs.writeFileSync("deployed.json", JSON.stringify({
    CCC: address
  }, null, 2));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
