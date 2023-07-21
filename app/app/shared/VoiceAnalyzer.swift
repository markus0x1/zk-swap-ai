//
//  VoiceAnalyzer.swift
//  app
//
//  Created by Jann Driessen on 21.07.23.
//

import Foundation

struct VoiceAnalyzerResponse: Decodable {
    // TODO: parse symbols to addresses?
    let inputToken: String
    let outputToken: String
    // TODO: parse to BigInt?
    let inputAmount: Double
}

class VoiceAnalyzer {
    private let openAIService: OpenAIService

    init(openAIService: OpenAIService) {
        self.openAIService = openAIService
    }

    func analyzeText(_ text: String) async -> VoiceAnalyzerResponse?  {
        // TODO: just for testing
//        return VoiceAnalyzerResponse(inputToken: "ETH", outputToken: "USDC", inputAmount: 0.01)
        guard let resOpenAI = try? await openAIService.requestCompletion(with: text) else { return nil }
        guard let parsedRes = try? parseOpenAIResponse(resOpenAI) else { return nil }
        return parsedRes
    }

    private func parseOpenAIResponse(_ res: OpenAIResponse) throws -> VoiceAnalyzerResponse? {
        print(res)
        guard let resText = res.choices.first?.text else { return nil }
        guard let jsonStartIndex = resText.firstIndex(of: "{") else { return nil }
        let startIndex = resText.index(jsonStartIndex, offsetBy: 0)
        let range = startIndex..<resText.endIndex
        let json = resText[range]
        let parsedResponse = try JSONDecoder().decode(VoiceAnalyzerResponse.self, from: Data(json.utf8))
        return parsedResponse
    }
}
