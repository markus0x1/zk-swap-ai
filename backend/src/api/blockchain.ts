import express from 'express';
import { balance, getBlockNumber, getPrice, getDexStats } from '../blockchain';

const router = express.Router();

router.get<{}, { balance: string }>('/balance', (req, res) => {
  balance().then((balance) => {
    res.json({ balance });
  });
});

router.get<{}, { height: number }>('/blockNumber', (req, res) => {
  getBlockNumber().then((height) => {
    res.json({ height });
  });
});

router.get<{ dex: string }, { price: string }>('/getPrice/:dex', (req, res) => {
  const { dex } = req.params;
  if (dex !== 'A' && dex !== 'B') {
    res.json({ price: "undefined" });
    return;
  }

  getPrice(dex).then((price) => {
    res.json({ price });
  });
});


router.get<{ dex: string }, {
  decimals0: string,
  decimals1: string,
  price: string,
  reserve0: string,
  reserve1: string,
  token0: string,
  token1: string,
  totalSupply: string
}>('/dexStats/:dex', (req, res) => {
  const { dex } = req.params;
  if (dex !== 'A' && dex !== 'B') {
    return res.json(undefined);
  }

  getDexStats(dex).then((stats) => {
    res.json(stats);
  });
});

export default router;

