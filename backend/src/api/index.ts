import express from 'express';
import blockchain from './blockchain';
import { findOptimalPath as findOptimalTrade } from '../pathfinder';
import { getDexState, getDy, tradeWithIntent } from '../ethereum';
import { generateProof } from '../prover';
import { Solution } from '../types/UserData';

const router = express.Router();

type Address = string;

type SwapRequest = {
  inToken: Address,
  outToken: Address,
  dx: bigint,
  minDy: bigint,
  forwardData: Uint8Array,
}
router.post<SwapRequest, { }>('/swap', async (req, res) => {

  const {
    inToken,
    outToken,
    dx,
    minDy,
    forwardData,
  }: SwapRequest = req.body;

  const trade = {
    inToken,
    outToken,
    dx,
    minDy,
  } 
  const dexA = await getDexState("A")
  const dexB = await getDexState("B")

  const estimatedDyA = await getDy("A", dx)
  const estimatedDyB = await getDy("B", dx)

  const { dxA, dxB, dyA, dyB } = findOptimalTrade(dexA, dexB, estimatedDyA, estimatedDyB, trade)

  const xA = BigInt(dexA.reserve0)
  const yA = BigInt(dexA.reserve1)
  const xB = BigInt(dexB.reserve0)
  const yB = BigInt(dexB.reserve1)

  const [proof] = await generateProof({ xA: xA, yA: yA, xB: xB, yB: yB, dxA, dxB, dyA, dyB })

  const solution: Solution = { dxA, dxB, ...proof }
  const recipt = await tradeWithIntent(forwardData, solution)
  await recipt.wait()

  res.json({ recipt });
});

router.use('/blockchain', blockchain)

export default router;
