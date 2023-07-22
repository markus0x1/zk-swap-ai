import { ProofTester, WitnessTester } from "circomkit";
import { circomkit } from "./common";

// based on https://github.com/erhant/circomkit-examples

const N = 128;

type CircuitInput = {
  xA: number;
  yA: number;
  xB: number;
  yB: number;
  dxA: number;
  dyA: number;
  dxB: number;
  dyB: number;
};
describe.only("aggregator", () => {
  let circuit: WitnessTester<["xA", "yA", "xB", "yB", "dxA", "dyA", "dxB", "dyB"], ["out"]>;
  let defaultValues: CircuitInput;

  before(async () => {
    circuit = await circomkit.WitnessTester(`aggregator_${N}`, {
      file: "aggregator",
      template: "Aggregator",
      params: [N],
    });
    console.log("#constraints:", await circuit.getConstraintCount());

    defaultValues = { xA: 10000, yA: 10, xB: 15000, yB: 10, dxA: 1000, dyA: 1, dxB: 0, dyB: 0 };
  });


  it("route everything through cheaper exchange", async () => {
    await circuit.expectPass(defaultValues);
  });

  it("unsorted values", async () => {
    let {xA, xB} = defaultValues;
    defaultValues.xA = xB;
    defaultValues.xB = xA;
    await circuit.expectFail(defaultValues);
  });

  it("too large trade", async () => {
    let { yA,  yB} = defaultValues;
    defaultValues.dyA = yA;
    defaultValues.dyB = yB;
    await circuit.expectFail(defaultValues);
  });

  
  it("route everything through expensive exchange", async () => {
    let { dxB, dyA, dyB,  dxA} = defaultValues;
    defaultValues.dxA = dxB;
    defaultValues.dxB = dxA;
    defaultValues.dyA = dyB;
    defaultValues.dyB = dyA;
    await circuit.expectFail(defaultValues);
  });

});


describe.only('proof tester', () => {
  type NewType = ProofTester<["xA", "yA", "xB", "yB", "dxA", "dyA", "dxB", "dyB"]>;
  let defaultValues: CircuitInput;

  // input signals and output signals can be given as type parameters
  // this makes all functions type-safe!
  let circuit: NewType;


  before(async () => {
    circuit = await circomkit.ProofTester(`aggregator_${N}`);
    defaultValues = { xA: 10000, yA: 10, xB: 15000, yB: 10, dxA: 1000, dyA: 1, dxB: 0, dyB: 0 };

  });

  it('should verify a proof correctly', async () => {
    const {proof, publicSignals} = await circuit.prove(defaultValues);
    // console.log('proof is', proof);
    // console.log('publicSignals is', publicSignals);

    await circuit.expectPass(proof, publicSignals);
  });

})