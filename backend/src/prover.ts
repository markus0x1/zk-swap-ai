import { Circomkit } from "circomkit";
import { Proof } from "./types/UserData";

export const circomkit = new Circomkit({
    circuits: "circuits/circuits.json",
    dirCircuits: "circuits/circuits",
    dirBuild: "circuits/build",
    dirInputs: "circuits/inputs",
    verbose: false,
});

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

const N = 128;

export const generateProof = async (input: CircuitInput): Promise<[Proof, string[]]> => {
    const circuit = await circomkit.ProofTester(`aggregator_${N}`);
    const { proof, publicSignals } = await circuit.prove(input);
    const sigma = proof as { pi_a: [string, string, string], pi_b: [[string, string], [string, string]], pi_c: [string, string, string] }
    await circuit.expectPass(proof, publicSignals);
    return [
        {
            _pA: [BigInt(sigma.pi_a[0]), BigInt(sigma.pi_a[1])],
            _pB: [
                [BigInt(sigma.pi_b[0][0]), BigInt(sigma.pi_b[0][1])],
                [BigInt(sigma.pi_b[1][0]), BigInt(sigma.pi_b[1][1])]
            ],
            _pC: [BigInt(sigma.pi_c[0]), BigInt(sigma.pi_c[1])]
        },
        publicSignals,
    ]
}