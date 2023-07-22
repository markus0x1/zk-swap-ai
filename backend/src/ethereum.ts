import IERC20Abi from '../../abis/IERC20.json';
import CPAMMAbi from '../../abis/CPAMM.json';
import PluginAbi from '../../abis/Plugin.json';
import Groth16Verifier from '../../abis/Groth16Verifier.json';
import { ethers, Signer, Contract, formatUnits, formatEther } from 'ethers';
import { UserData } from './types/UserData';

if (!process.env.TENDERLY_FORK_URL) {
    throw new Error('TENDERLY_FORK_URL is not set');
}
const TENDERLY_FORK_URL = process.env.TENDERLY_FORK_URL;

if (!process.env.PRIVATE_KEY) {
    throw new Error('PRIVATE_KEY is not set');
}
const PRIVATE_KEY = process.env.PRIVATE_KEY;

if (!process.env.DEX_A_ADDRESS) {
    throw new Error('DEX_A_ADDRESS is not set');
}
if (!process.env.DEX_B_ADDRESS) {
    throw new Error('DEX_B_ADDRESS is not set');
}
const DEX_A_ADDRESS = process.env.DEX_A_ADDRESS;
const DEX_B_ADDRESS = process.env.DEX_B_ADDRESS;

if (!process.env.WETH_ADDRESS) {
    throw new Error('WETH_ADDRESS is not set');
}
export const WETH_ADDRESS = process.env.WETH_ADDRESS;

if (!process.env.DAI_ADDRESS) {
    throw new Error('DAI_ADDRESS is not set');
}
export const DAI_ADDRESS = process.env.DAI_ADDRESS;


if (!process.env.SAFE_MODULE_ADDRESS) {
    throw new Error('SAFE_MODULE_ADDRESS is not set');
}
const SAFE_MODULE_ADDRESS = process.env.SAFE_MODULE_ADDRESS;

if (!process.env.GROTH16_VERIFIER_ADDRESS) {
    throw new Error('GROTH16_VERIFIER_ADDRESS is not set');
}
const GROTH16_VERIFIER_ADDRESS = process.env.GROTH16_VERIFIER_ADDRESS;

const provider = new ethers.JsonRpcProvider(TENDERLY_FORK_URL);

const wallet = new ethers.Wallet(PRIVATE_KEY, provider)

let _signer: Signer | undefined = undefined;
const signer = async () => {
    if (_signer == undefined) {
        _signer = await provider.getSigner()
    }
    return _signer
}

const dexBContract = new Contract(DEX_B_ADDRESS, CPAMMAbi.abi, wallet)
const dexAContract = new Contract(DEX_A_ADDRESS, CPAMMAbi.abi, wallet)

const moduleContract = new Contract(SAFE_MODULE_ADDRESS, PluginAbi.abi, wallet)
// const moduleContract = _moduleContract.connect(wallet)

const daiErc20Contract = new Contract(DAI_ADDRESS, IERC20Abi.abi, wallet)
const wethErc20Contract = new Contract(WETH_ADDRESS, IERC20Abi.abi, wallet)

const verifierContract = new Contract(GROTH16_VERIFIER_ADDRESS, Groth16Verifier.abi, wallet)

export const getBlockNumber = provider.getBlockNumber;

export const balance = async () => {
    const balance = await provider.getBalance("ethers.eth");

    return formatEther(balance);
}

export const getPrice = async (exchange: "A" | "B") => {
    const dex = await getDex(exchange);
    const res = await dex.price()
    const decimals0 = await dex.decimals0()
    const decimals1 = await dex.decimals1()
    console.log({ res, decimals0, decimals1 })
    return formatUnits(res, decimals0)
}

export const getDexState = async (exchange: "A" | "B"): Promise<{
    decimals0: string,
    decimals1: string,
    price: string,
    reserve0: string,
    reserve1: string,
    token0: string,
    token1: string,
    totalSupply: string
}> => {
    const dex = await getDex(exchange);

    const decimals0 = await dex.decimals0()
    const decimals1 = await dex.decimals0()
    const price = await dex.price()
    const reserve0 = await dex.reserve0()
    const reserve1 = await dex.reserve1()
    const token0 = await dex.token0()
    const token1 = await dex.token1()
    const totalSupply = await dex.totalSupply()

    console.log({ decimals0, decimals1, price, reserve0, reserve1, token0, token1, totalSupply })

    return {
        decimals0: decimals0,
        decimals1: decimals1,
        price: price,
        reserve0: reserve0,
        reserve1: reserve1,
        token0,
        token1,
        totalSupply: totalSupply,
    }
}
// struct Solution {
//     uint256 dxA;
//     uint256 dxB;
//     uint256[2] _pA;
//     uint256[2][2] _pB;
//     uint256[2] _pC;
// }
interface Solution extends Proof {
    dxA: bigint;
    dxB: bigint;
}

interface Proof {
    _pA: [bigint, bigint];
    _pB: [[bigint, bigint], [bigint, bigint]];
    _pC: [bigint, bigint];
}

export const tradeWithIntent = (userData: UserData, solution: Solution) => {
    return moduleContract.tradeWithIntent(userData, solution)
}

export const getDex = async (exchange: "A" | "B") => {
    return exchange === 'A' ? dexAContract : dexBContract;
}

export const getDy = async (exchange: "A" | "B", dx: bigint, inToken: string) => {
    return exchange === 'A' ? dexAContract.get_dy(dx, inToken) : dexBContract.get_dy(dx, inToken);
}

export const verifyProof = (proof: Proof, publicSignals: string[]) => {
    return verifierContract.verifyProof(proof._pA, proof._pB, proof._pC, publicSignals)
}