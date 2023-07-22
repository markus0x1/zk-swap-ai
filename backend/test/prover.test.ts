import { ProofTester, WitnessTester } from "circomkit";
import { generateProof, circomkit } from "../src/prover";
import { verifyProof } from "../src/ethereum";

// based on https://github.com/erhant/circomkit-examples

const N = 128;

type CircuitInput = {
    xA: bigint;
    yA: bigint;
    xB: bigint;
    yB: bigint;
    dxA: bigint;
    dyA: bigint;
    dxB: bigint;
    dyB: bigint;
};

describe.only('proof tester', () => {
    type NewType = ProofTester<["xA", "yA", "xB", "yB", "dxA", "dyA", "dxB", "dyB"]>;
    let defaultValues: CircuitInput;

    // input signals and output signals can be given as type parameters
    // this makes all functions type-safe!
    let circuit: NewType;


    beforeEach(async () => {
        circuit = await circomkit.ProofTester(`aggregator_${N}`);
        defaultValues = { xA: 10000n, yA: 10n, xB: 15000n, yB: 10n, dxA: 1000n, dyA: 1n, dxB: 0n, dyB: 0n };

    });

    it('should verify a proof correctly', async () => {
        const [sigma, publicSignals] = await generateProof(defaultValues)
        const result = await verifyProof(sigma, publicSignals)
        expect(result).toBe(true)
    });

    it('should verify a proof correctly for actual inputs', async () => {
        const inputs = {
            xA: 9101000000n,
            yA: 988935277n,
            xB: 1000000000n,
            yB: 100000000n,
            dxA: 0n,
            dxB: 1n,
            dyA: 0n,
            dyB: 1n
        }
        const [sigma, publicSignals] = await generateProof(inputs)
        const result = await verifyProof(sigma, publicSignals)
        expect(result).toBe(true)
    });
})