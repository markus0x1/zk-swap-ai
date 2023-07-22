
import request from 'supertest';

import app from '../src/app';
import { DAI_ADDRESS, WETH_ADDRESS } from '../src/ethereum';

describe('POST /api/swap', () => {
    it('responds with a json message', (done) => {
        request(app)
            .post('/api/swap')
            .send({
                safeAddress: '0x123',
                inToken: WETH_ADDRESS,
                outToken: DAI_ADDRESS,
            })
            .set('Accept', 'application/json')
            .expect('Content-Type', /json/)
            .expect(200, {
                message: 'API - 👋🌎🌍🌏',
            }, done);
    });
});
