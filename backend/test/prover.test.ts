import { ProofTester, WitnessTester } from "circomkit";
import { generateProof, circomkit } from "../src/prover";

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

describe.only('proof tester', () => {
    type NewType = ProofTester<["xA", "yA", "xB", "yB", "dxA", "dyA", "dxB", "dyB"]>;
    let defaultValues: CircuitInput;

    // input signals and output signals can be given as type parameters
    // this makes all functions type-safe!
    let circuit: NewType;


    beforeEach(async () => {
        circuit = await circomkit.ProofTester(`aggregator_${N}`);
        defaultValues = { xA: 10000, yA: 10, xB: 15000, yB: 10, dxA: 1000, dyA: 1, dxB: 0, dyB: 0 };

    });

    it('should verify a proof correctly', async () => {
        const sigma  = await generateProof(defaultValues)
        const {publicSignals} = await circuit.prove(defaultValues);

        await circuit.expectPass(sigma, publicSignals);
    });

})