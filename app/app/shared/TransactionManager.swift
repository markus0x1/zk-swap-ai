//
//  TransactionManager.swift
//  app
//
//  Created by Jann Driessen on 21.07.23.
//

import Combine
import Foundation
import metamask_ios_sdk

class TransactionManager {
    let connectionManager: ConnectionManager
    private (set) var voiceResponse: VoiceAnalyzerResponse?
    private var cancellables: Set<AnyCancellable> = []

    private (set) var outputTokenSymbol: String = "DAI"
    private (set) var outputTokenAmount: String = "0.1"

    init(connectionManager: ConnectionManager) {
        self.connectionManager = connectionManager
    }

    func setVoiceResponse(_ response: VoiceAnalyzerResponse) {
        self.voiceResponse = response
    }

    func signAndSend() async throws {
        print("signAndSend")
    }
}
