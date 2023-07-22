import IERC20 from '../../abis/IERC20.json';
import CPAMM from '../../abis/CPAMM.json';
import { ethers, Signer, Contract, formatUnits, formatEther } from 'ethers';

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

const WETH_ADDRESS = process.env.DEX_A_ADDRESS;
const DAI_ADDRESS = process.env.DEX_A_ADDRESS;

const provider = new ethers.JsonRpcProvider(TENDERLY_FORK_URL);

const wallet = new ethers.Wallet(PRIVATE_KEY, provider)

let _signer: Signer | undefined = undefined;
const signer = async () => {
    if (_signer == undefined) {
        _signer = await provider.getSigner()
    }
    return _signer
}

const dexBContract = new Contract(DEX_B_ADDRESS, CPAMM.abi, wallet)
const dexAContract = new Contract(DEX_A_ADDRESS, CPAMM.abi, wallet)

const daiErc20Contract = new Contract(DAI_ADDRESS, IERC20.abi, wallet)
const wethErc20Contract = new Contract(WETH_ADDRESS, IERC20.abi, wallet)

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
        decimals0: formatUnits(decimals0, decimals0),
        decimals1: formatUnits(decimals1, decimals1),
        price: formatUnits(price, decimals0),
        reserve0: formatUnits(reserve0, decimals0),
        reserve1: formatUnits(reserve1, decimals1),
        token0,
        token1,
        totalSupply: formatUnits(totalSupply, decimals0)
    }

}

const getDex = async (exchange: "A" | "B") => {
    return exchange === 'A' ? dexAContract : dexBContract;
}