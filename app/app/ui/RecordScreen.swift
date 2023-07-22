//
//  RecordScreen.swift
//  app
//
//  Created by Jann Driessen on 21.07.23.
//

import Foundation
import Foundation
import AVFoundation
import Speech
import SwiftUI

extension AVPlayer {
    static let sharedDingPlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "ding", withExtension: "wav") else { fatalError("Failed to find sound file.") }
        return AVPlayer(url: url)
    }()
}

struct RecordScreen: View {
    @ObservedObject private var connectionManager: ConnectionManager
    private let transactionManager: TransactionManager
    @State private var isPresented = false

    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isTalking = false

    @State var transcript = "test"

    private var player: AVPlayer { AVPlayer.sharedDingPlayer }

    init(connectionManager: ConnectionManager) {
        self.connectionManager = connectionManager
        self.transactionManager = TransactionManager(connectionManager: connectionManager)
    }

    var body: some View {
        VStack {
//            Text(transcript)
            GlowingButton(isTalking: $isTalking)
                .onTapGesture {
                    Task.init {
                        speechRecognizer.resetTranscript()
                        speechRecognizer.startTranscribing()
                        isTalking = true
                        // wait for 1 sec to simulate listening
                        try await Task.sleep(nanoseconds: 10_000_000_000)
                        speechRecognizer.stopTranscribing()
                        transcript = speechRecognizer.transcript
                        let openAI = OpenAIService()
                        let analyzer = VoiceAnalyzer(openAIService: openAI)
                        let res = await analyzer.analyzeText(transcript)
                        print("////OPENAIRES")
                        print(res)
                        transactionManager.setVoiceResponse(res!)
//                        isPresented = true
                    }
                }
            Text("Say something like\n'I wanna swap 0.1 ETH for USDC'")
                .font(.system(size: 14))
                .foregroundColor(Color.gray)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.top, 45)
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $isPresented) {
            ConfirmationScreen(transactionManager: transactionManager)
        }
    }
}

struct RecordScreen_Previews: PreviewProvider {
    static var previews: some View {
        RecordScreen(connectionManager: ConnectionManager())
    }
}
