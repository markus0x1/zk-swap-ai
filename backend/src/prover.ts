import { Circomkit } from "circomkit";

export const circomkit = new Circomkit({
    circuits: "circuits/circuits.json",
    dirCircuits: "circuits/circuits",
    dirBuild: "circuits/build",
    dirInputs: "circuits/inputs",
    verbose: false,
});

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

const N = 128;

export const generateProof = async (input: CircuitInput): Promise<object> => {
    const circuit = await circomkit.ProofTester(`aggregator_${N}`);
    const { proof, publicSignals } = await circuit.prove(input);
    console.log({ proof })
    await circuit.expectPass(proof, publicSignals);
    return proof
}