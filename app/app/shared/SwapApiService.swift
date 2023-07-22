//
//  SwapApiService.swift
//  app
//
//  Created by Jann Driessen on 22.07.23.
//

import Foundation

struct SwapApiSendTxRequest: Encodable {
    let safeAddress: String
    let inToken: String
    let outToken: String
    let dx: String
    let minDy: String
    let nonce: String
    let signature: String
}

// TODO:
struct SwapApiSendTxResponse: Decodable {
    let amountOut: String
    // TODO:
}

class SwapApiService {
    private let apiUrl = "http://localhost:8545/api/swap"
    /// - param data: params encoded data as hex string
    func sendTx(with data: String) async throws -> SwapApiSendTxResponse? {
        print("Requesting completion for:", data)
        let sendTxRequest = SwapApiSendTxRequest(
            safeAddress: Config.Constants.safeAddress,
            inToken: Config.Constants.WETH,
            outToken: Config.Constants.DAI,
            dx: "10000000000000000",
            minDy: "0",
            nonce: "0",
            signature: "0x000000000000000000000000000000000000dead"
        )
        guard let url = URL(string: apiUrl) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try JSONEncoder().encode(sendTxRequest)
        print(request)
        let (data, response) = try await URLSession.shared.data(for: request)
        print(response)
        let res = try JSONDecoder().decode(SwapApiSendTxResponse.self, from: data)
        return res
    }
}
