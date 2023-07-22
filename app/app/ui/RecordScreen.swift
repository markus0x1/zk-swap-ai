//
//  RecordScreen.swift
//  app
//
//  Created by Jann Driessen on 21.07.23.
//

import SwiftUI

struct RecordScreen: View {
    @ObservedObject private var connectionManager: ConnectionManager
    private let transactionManager: TransactionManager
    @State private var isTalking = false
    @State private var isPresented = false
    init(connectionManager: ConnectionManager) {
        self.connectionManager = connectionManager
        self.transactionManager = TransactionManager(connectionManager: connectionManager)
    }
    var body: some View {
        VStack {
            GlowingButton(isTalking: $isTalking)
                .onTapGesture {
                    Task.init {
                        isTalking = true
                        // wait for 1 sec to simulate listening
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                        let openAI = OpenAIService()
                        let analyzer = VoiceAnalyzer(openAIService: openAI)
                        // FIXME: note some of the classes only return dummy data for now (change for production)
                        // TODO: use result of voice recording (text)
                        let res = await analyzer.analyzeText("I want to swap 1 ETH to USDC")
                        print("////OPENAIRES")
                        print(res)
                        transactionManager.setVoiceResponse(res!)
                        isPresented = true
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
