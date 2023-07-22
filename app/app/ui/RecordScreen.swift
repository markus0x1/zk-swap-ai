//
//  RecordScreen.swift
//  app
//
//  Created by Jann Driessen on 21.07.23.
//

import SwiftUI

struct RecordScreen: View {
    private let transactionManager = TransactionManager()
    @State private var isPresented = false
    var body: some View {
        Button("TalkToMe") {
            Task.init {
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
        .navigationDestination(isPresented: $isPresented) {
            ConfirmationScreen(transactionManager: transactionManager)
        }
    }
}

struct RecordScreen_Previews: PreviewProvider {
    static var previews: some View {
        RecordScreen()
    }
}
