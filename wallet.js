import { ethers } from "ethers";

export async function connectWallet() {
  if (!window.ethereum) {
    alert("Instale MetaMask");
    return;
  }

  const provider = new ethers.BrowserProvider(window.ethereum);
  const accounts = await provider.send("eth_requestAccounts", []);

  const signer = await provider.getSigner();

  return {
    address: accounts[0],
    signer
  };
}
