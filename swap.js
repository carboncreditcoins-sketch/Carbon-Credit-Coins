import { ethers } from "ethers";

const ROUTER = "0xE592427A0AEce92De3Edee1F18E0157C05861564"; // Uniswap V3

export async function swapETHtoToken(signer, tokenOut, amountIn) {
  const routerAbi = [
    "function exactInputSingle(tuple(address,address,uint24,address,uint256,uint256,uint160)) payable returns (uint256)"
  ];

  const router = new ethers.Contract(ROUTER, routerAbi, signer);

  const params = {
    tokenIn: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
    tokenOut: tokenOut,
    fee: 3000,
    recipient: await signer.getAddress(),
    deadline: Math.floor(Date.now() / 1000) + 60 * 10,
    amountIn: ethers.parseEther(amountIn),
    amountOutMinimum: 0,
    sqrtPriceLimitX96: 0
  };

  const tx = await router.exactInputSingle(params, {
    value: ethers.parseEther(amountIn)
  });

  await tx.wait();
}
