//
//  TransactionManager.swift
//  app
//
//  Created by Jann Driessen on 21.07.23.
//

import Foundation

class TransactionManager {
    private (set) var voiceResponse: VoiceAnalyzerResponse?

    func setVoiceResponse(_ response: VoiceAnalyzerResponse) {
        self.voiceResponse = response
    }

    func signAndSend() async throws {
        print("signAndSend")
    }
}
