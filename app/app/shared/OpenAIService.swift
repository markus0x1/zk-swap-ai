//
//  OpenAIService.swift
//  app
//
//  Created by Jann Driessen on 21.07.23.
//

import Foundation

struct OpenAIChoice: Decodable {
    let text: String
}

struct OpenAIRequest: Encodable {
    let model = "text-davinci-003"
    let prompt: String
    let temperature: Int = 0
    let max_tokens: Int = 100
    let top_p: Int = 1
    let frequency_penalty: Double = 0.2
    let presence_penalty: Int = 0
}

struct OpenAIResponse: Decodable {
    let id: String
    let model: String
    let choices: [OpenAIChoice]
}

class OpenAIService {
    private let apiUrl = "https://api.openai.com/v1/completions"
    private let promptTemplate = "Convert this text to a programmatic command:\n\nExample: I want to swap 100 USDC for ETH\nOutput: {\"inputToken\": \"USDC\", \"inputAmount\": 100, \"outputToken\": \"ETH\"}"
    /// Fetches model response for the given prompt
    func requestCompletion(with prompt: String) async throws -> OpenAIResponse? {
        print("Requesting completion for:", prompt)
        // FIXME: delete dummy response
        return OpenAIService.dummyResponse
        let model = OpenAIRequest(prompt: "\(promptTemplate)\n\n\(prompt)")
        guard let url = URL(string: apiUrl) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue("Bearer \(Config.apiKeyOpenAI)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(model)
        print(request)
        let (data, _) = try await URLSession.shared.data(for: request)
        let res = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return res
    }
}

private extension OpenAIService {
    static var dummyChoice: OpenAIChoice {
        return OpenAIChoice(
            text: "\nOutput: {\"inputToken\": \"ETH\", \"inputAmount\": 0.1, \"outputToken\": \"DAI\"}"
        )
    }
    /// Just for testing, to not waste credits
    static var dummyResponse: OpenAIResponse {
        return OpenAIResponse(
            id: "cmpl-7eqFTk5YRI5iIbrZsFk4s3FDmzBav",
            model: "text-davinci-003",
            choices: [dummyChoice]
        )
    }
}
