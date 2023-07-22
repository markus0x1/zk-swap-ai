//
//  TransactionManager.swift
//  app
//
//  Created by Jann Driessen on 21.07.23.
//

import Foundation

class TransactionManager {
    let connectionManager: ConnectionManager
    private (set) var voiceResponse: VoiceAnalyzerResponse?
    private (set) var outputTokenSymbol: String = "DAI"
    var outputTokenAmount: String = "189.5"

    init(connectionManager: ConnectionManager) {
        self.connectionManager = connectionManager
    }

    func setVoiceResponse(_ response: VoiceAnalyzerResponse) {
        self.voiceResponse = response
        self.outputTokenSymbol = response.outputToken
    }
}
