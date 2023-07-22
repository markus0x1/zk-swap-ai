import express from 'express';
import blockchain from './blockchain';
import { findOptimalPath as findOptimalTrade } from '../pathfinder';
import { getDexState, getDy, tradeWithIntent } from '../ethereum';
import { generateProof } from '../prover';
import { Solution } from '../types/UserData';
import { formatUnits } from 'ethers';

const router = express.Router();

type Address = string;

type SwapRequest = {
  safeAddress: Address;
  inToken: Address;
  outToken: Address;
  dx: string;
  minDy: string;
  nonce: string;
  signature: ArrayBuffer;
};
router.post<SwapRequest, {}>('/swap', async (req, res) => {
  console.log(req.body);
  const signature = req.body.signature;
  const dx = BigInt(req.body.dx);
  const safeAddress = req.body.safeAddress;
  const nonce = req.body.nonce;
  if (!req.body.inToken.startsWith('0x')) {
    return res.status(400).json({ error: 'inToken must start with 0x' });
  }
  if (!req.body.outToken.startsWith('0x')) {
    return res.status(400).json({ error: 'outToken must start with 0x' });
  }
  const inToken = req.body.inToken;
  const outToken = req.body.outToken;
  const trade = {
    inToken,
    outToken,
    dx: dx,
    minDy: BigInt(req.body.minDy),
  };

  const [dexA, dexB, estimatedDyA, estimatedDyB] = await Promise.all([getDexState('A'), getDexState('B'), getDy('A', dx, inToken), getDy('B', dx, inToken)]);

  const { dxA, dxB, dyA, dyB } = findOptimalTrade(
    dexA,
    dexB,
    estimatedDyA,
    estimatedDyB,
    trade,
  );

  const xA = BigInt(dexA.reserve0);
  const yA = BigInt(dexA.reserve1);
  const xB = BigInt(dexB.reserve0);
  const yB = BigInt(dexB.reserve1);

  console.log("Generating proof for trade", { xA, yA, xB, yB, dxA, dxB, dyA, dyB })
  const [proof] = await generateProof({
    xA,
    yA,
    xB,
    yB,
    dxA,
    dxB,
    dyA,
    dyB,
  });
  console.log({ proof })

  const solution: Solution = { dxA, dxB, ...proof };
  const userData = { safe: safeAddress, ...trade, nonce, signature };
  console.log("Trade with intent", { userData, solution })
  const recipt = await tradeWithIntent(userData, solution);
  const receiptResponse = await recipt.wait();
  res.json({ txHash: receiptResponse.hash, amountIn: formatUnits(dx, dexA.decimals0),  amountOut: dyA > dyB ? formatUnits(dyA, dexA.decimals1) : formatUnits(dyB, dexB.decimals1) });
});

router.use('/blockchain', blockchain);

export default router;
