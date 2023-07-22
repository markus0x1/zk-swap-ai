export interface UserData {
        inToken: string;
        outToken: string;
        dx: bigint;
        minDy: bigint;
        nounce: bigint;
        signature: ArrayBuffer;
}

// struct Solution {
//     uint256 dxA;
//     uint256 dxB;
//     uint256[2] _pA;
//     uint256[2][2] _pB;
//     uint256[2] _pC;
// }
export interface Solution extends Proof {
    dxA: bigint;
    dxB: bigint;
}

export interface Proof {
    _pA: [bigint, bigint];
    _pB: [[bigint, bigint], [bigint, bigint]];
    _pC: [bigint, bigint];
}