import express from 'express';
import blockchain from './blockchain';

const router = express.Router();

router.post<{
  inToken: string,
  outToken: string,
  amount: number,
  minOut: number,
  nonce: number,
  signature: string
}, { message: string }>('/swap', (req, res) => {
  const {
    inToken,
    outToken,
    amount,
    minOut,
    nonce,
    signature,
  } = req.body;

  res.json(req.body);
});

router.use('/blockchain', blockchain)

export default router;
