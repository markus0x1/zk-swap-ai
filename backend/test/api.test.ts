
import request from 'supertest';

import app from '../src/app';
import { DAI_ADDRESS, WETH_ADDRESS } from '../src/ethereum';


describe('POST /api/swap', () => {
    it('responds with a json message', (done) => {
        const req = {
            safeAddress: "0x1367D7E411Df11c261e0Dd5a632c2f5d0245A095",
            inToken:WETH_ADDRESS,
            outToken: DAI_ADDRESS,
            dx: "100000000000000000",
            minDy: "0",
            nonce: "1",
            signature: "0x0000000000000000000000000000000000000000",
        }
        console.log({req})
        request(app)
            .post('/api/swap')
            .send(req)
            .set('Content-Type', 'application/json')
            .set('Accept', 'application/json')
            .expect(200)
            .end(function (err, res) {
                if (err) throw err;
                console.log(res.body);
                done();
            });
    }, 1000000);
});
