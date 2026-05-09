import express from "express";
import { ethers } from "ethers";
import dotenv from "dotenv";

dotenv.config();

const app = express();
app.use(express.json());

const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

const abi = [
  "function transfer(address to, uint amount) public returns (bool)",
  "function balanceOf(address account) view returns (uint)"
];

const contract = new ethers.Contract(
  process.env.CONTRACT_ADDRESS,
  abi,
  wallet
);

// 🔥 envio automático
app.post("/send", async (req, res) => {
  try {
    const { to, amount } = req.body;

    const tx = await contract.transfer(
      to,
      ethers.parseUnits(amount, 18)
    );

    await tx.wait();

    res.json({ success: true, hash: tx.hash });

  } catch (err) {
    res.json({ error: err.message });
  }
});

// saldo
app.get("/balance/:wallet", async (req, res) => {
  const balance = await contract.balanceOf(req.params.wallet);
  res.json({ balance: ethers.formatUnits(balance, 18) });
});

app.listen(3000, () => {
  console.log("Servidor rodando na porta 3000");
});
