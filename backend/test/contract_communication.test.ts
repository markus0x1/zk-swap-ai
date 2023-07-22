import { DAI_ADDRESS, WETH_ADDRESS, getDy } from "../src/ethereum";

describe.only('proof ethereum calls', () => {
    it('getDy', async () => {
        const dYDai = await getDy("A", 1n, DAI_ADDRESS)
        console.log(dYDai)
        const dYWeth = await getDy("A", 1n, WETH_ADDRESS)
        console.log(dYWeth)
        expect(dYWeth).toBeDefined()
    });

})