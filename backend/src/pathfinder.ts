import { AMMState } from './types/AMMState';
import { Trade } from './types/Trade';

//TODO: write pathfinder
type OptimalRoute = { dxA: bigint; dxB: bigint; dyA: bigint; dyB: bigint };

export const findOptimalPath = (
  dexA: AMMState,
  dexB: AMMState,
  estimatedDyA: bigint,
  estimatedDyB: bigint,
  trade: Trade,
): OptimalRoute => {
  // mock optimal pathfinder algoritm
  if (estimatedDyA > estimatedDyB) {
    return { dxA: trade.dx, dxB: 0n, dyA: estimatedDyA, dyB: 0n };
  } else {
    return { dxA: 0n, dxB: trade.dx, dyA: 0n, dyB: estimatedDyB };
  }
};
