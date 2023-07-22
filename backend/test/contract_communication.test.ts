import { DAI_ADDRESS, WETH_ADDRESS, getDy } from "../src/ethereum";

describe.only('ethereum calls', () => {
    it('getDy', async () => {
        const dYDai = await getDy("A", 1n, DAI_ADDRESS)
        expect(dYDai).toBeGreaterThan(0n)

        const dYWeth = await getDy("A", 1n, WETH_ADDRESS)
        expect(dYWeth).toBeGreaterThan(0n)
    });

})