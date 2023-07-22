export interface Trade {
    inToken: string,
    outToken: string,
    dx: bigint,
    minDy: bigint,
}