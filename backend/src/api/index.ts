import express from 'express';
import blockchain from './blockchain';
import { findOptimalPath } from '../pathfinder';
import { getDexState } from '../ethereum';
import { generateProof } from '../prover';

const router = express.Router();

router.post<{
  inToken: string,
  outToken: string,
  amount: number,
  minOut: number,
  nonce: number,
  signature: string
}, { }>('/swap', async (req, res) => {
  const {
    inToken,
    outToken,
    amount,
    minOut,
    nonce,
    signature,
  } = req.body;

  const trade: Trade =  {
    inToken,
    outToken,
    amount,
    minOut,
  }
  const stateA = await getDexState("A")
  const stateB = await getDexState("B")

  const path = findOptimalPath(stateA, stateB, trade)
  const sigma = generateProof({ xA: 10000, yA: 10, xB: 15000, yB: 10, dxA: 1000, dyA: 1, dxB: 0, dyB: 0 })

  res.json({ path, proof: sigma });
});

router.use('/blockchain', blockchain)

export default router;
