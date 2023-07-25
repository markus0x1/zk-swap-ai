import express from 'express';
import blockchain from './blockchain';
import { findOptimalPath as findOptimalTrade } from '../pathfinder';
import { getDexesState, sendTransactionToModule } from '../ethereum';
import { generateProof } from '../prover';
import { Address } from '../types/UserData';
import { formatUnits } from 'ethers';

const router = express.Router();

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
  console.log("Received swap request:\n" + JSON.stringify(req.body, null, 2));
  if (!req.body.inToken.startsWith('0x')) {
    return res.status(400).json({ error: 'inToken must start with 0x' });
  }
  if (!req.body.outToken.startsWith('0x')) {
    return res.status(400).json({ error: 'outToken must start with 0x' });
  }

  const { inToken, outToken, signature, safeAddress, nonce } = req.body;
  const dx = BigInt(req.body.dx);
  const minDy = BigInt(req.body.minDy);

  const trade = { inToken, outToken, dx, minDy };

  const [
    dexA,
    dexB,
    estimatedDyA,
    estimatedDyB
  ] = await getDexesState(dx, inToken)

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

  const receiptResponse = await sendTransactionToModule(dxA, dxB, proof, safeAddress, trade, nonce, signature);

  res.json({
    txHash: receiptResponse.hash,
    amountIn: formatUnits(dx, dexA.decimals0),
    amountOut: dyA > dyB ?
      formatUnits(dyA, dexA.decimals1) : formatUnits(dyB, dexB.decimals1)
  });
});

router.use('/blockchain', blockchain);

export default router;
