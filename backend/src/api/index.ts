import express from 'express';
import blockchain from './blockchain';
import { findOptimalPath as findOptimalTrade } from '../pathfinder';
import { getDexState, getDy, tradeWithIntent } from '../ethereum';
import { generateProof } from '../prover';
import { Solution } from '../types/UserData';

const router = express.Router();

type Address = string;

type SwapRequest = {
  safeAddress: Address,
  inToken: Address,
  outToken: Address,
  dx: string,
  minDy: string,
  nounce: string,
  signature: ArrayBuffer,
}
router.post<SwapRequest, {}>('/swap', async (req, res) => {

  const signature = req.body.signature
  const dx = BigInt(req.body.dx)
  const safeAddress = req.body.safeAddress;
  const nounce = req.body.nounce;
  if (!req.body.inToken.startsWith("0x")) {
    return res.status(400).json({ error: "inToken must start with 0x" })
  }
  if (!req.body.outToken.startsWith("0x")) {
    return res.status(400).json({ error: "outToken must start with 0x" })
  }
  const inToken = req.body.inToken;
  const outToken = req.body.outToken;
  const trade = {
    inToken,
    outToken,
    dx: dx,
    minDy: BigInt(req.body.minDy),
  }

  const dexA = await getDexState("A")
  const dexB = await getDexState("B")

  const estimatedDyA = await getDy("A", dx, inToken)
  const estimatedDyB = await getDy("B", dx, inToken)

  const { dxA, dxB, dyA, dyB } = findOptimalTrade(dexA, dexB, estimatedDyA, estimatedDyB, trade)

  const xA = BigInt(dexA.reserve0)
  const yA = BigInt(dexA.reserve1)
  const xB = BigInt(dexB.reserve0)
  const yB = BigInt(dexB.reserve1)

  const [proof] = await generateProof({ xA: xA, yA: yA, xB: xB, yB: yB, dxA, dxB, dyA, dyB })

  const solution: Solution = { dxA, dxB, ...proof }
  const userData = { safeAddress, ...trade , nounce, signature }
  const recipt = await tradeWithIntent(userData, solution)
  await recipt.wait()

  res.json({ recipt });
});

router.use('/blockchain', blockchain)

export default router;
