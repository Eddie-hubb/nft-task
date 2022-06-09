async function main() {
    const MyNFT = await ethers.getContractFactory("MyNFT")
    //A ContractFactory in ethers.js is an abstraction used to deploy new smart contracts, so MyNFT here is a factory for instances of our NFT contract.
    // Start deployment, returning a promise that resolves to a contract object
    const myNFT = await MyNFT.deploy() //return a Promise that resolves to a Contract
    await myNFT.deployed()
    console.log("Contract deployed to address:", myNFT.address)
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
  