pragma circom 2.1.0;

include "../lib/circomlib/circuits/comparators.circom";

// We have 3 different cases:

/* 
  1. split
  (xA + dxA) / (yA - dyA) = (xB + dxB) / (yB - dyB) 
  (xA + dxA) * (yB - dyB) = (xB + dxB) * (yA - dyA)

  2. only A
  (xA + dxA) / (yA - dyA) <= (xB / yB) * (1 + f) 
  (xA + dxA) * yB         <= xB * (yA - dyA) * (1 + f)

  3. only B
  (xB + dxB) / (yB - dyB) <= xA / yA * (1 + f)  
  yA  * (xB + dxB)        <= xA * (yB - dyB) * (1 + f)


A generalize approximation of above equations is to just prove that:
(xA + dxA) * (yB - dyB)   <= (xB + dxB) * (yA - dyA) * (1 + f)
xAnew * yBnew  * one      <= xBnew * yAnew * onePlusFee

  ,where A is the "cheaper" exchange: i.e. xA / yA < xB / yB <=> xA * yB < xB * yA

Hint: 
1) f = 0 
2) dxB = dyB = 0 
3) dxA = dyA = 0 

*/

// Amm aggregator condition
template Aggregator(n) {
  signal input xA, yA, xB, yB, dxA, dyA, dxB, dyB;

  // enforce that the exchange are sorted correctly -> xA: 10_000, yA: 10, xB: 15_000, yB: 10
  signal xAyB <== xA * yB; 
  signal xByA <== xB * yA;
  signal sorted <== 1; // LessEqThan(n)([xAyB, xByA]);
  sorted === 1;

  // new balances
  signal xAnew <== xA + dxA;
  signal xBnew <== xB + dxB;
  signal yAnew <== yA - dyA;
  signal yBnew <== yB - dyB;

  // enforce that the new balances are positive
  signal liquidityA <== LessThan(n)([dyA, yA]);
  signal liquidityB <==  LessThan(n)([dyB, yB]);
  liquidityA === 1;
  liquidityB === 1;

  // enforce arbitrage condition
  // // xAnew * yBnew  * one      <= xBnew * yAnew * onePlusFee
  var one = 1000;
  var f = 3;
  var onePlusFee = one + f;
  signal left <== xAnew * yBnew * one;     
  signal right <== xBnew * yAnew  * onePlusFee;
  signal output out <== 1; // <== // LessEqThan(n)([left, right]); 
}

