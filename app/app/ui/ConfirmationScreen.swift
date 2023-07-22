//
//  ConfirmationScreen.swift
//  app
//
//  Created by Jann Driessen on 21.07.23.
//

import SwiftUI

struct ConfirmationScreen: View {
    let transactionManager: TransactionManager
    @State private var isPresented = false
    var body: some View {
        VStack {
            Text("Swap \(txDetails.inputAmount) \(txDetails.inputToken) for \(txDetails.outputToken)")
            Spacer()
            Button("Sign&Send") {
                Task.init {
                    do {
                        try await transactionManager.signAndSend()
                        // TODO: only forward once tx is done?
                        // TODO: pass tx information (to display on next screen)?
                        isPresented = true
                    } catch {
                        print("Error sending tx", error)
                    }
                }
            }
        }
        .padding()
        .navigationDestination(isPresented: $isPresented) {
            SuccessScreen()
        }
    }
    private var txDetails: VoiceAnalyzerResponse {
        return transactionManager.voiceResponse ?? VoiceAnalyzerResponse(inputToken: "", outputToken: "", inputAmount: 0)
    }
}

struct ConfirmationScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationScreen(transactionManager: TransactionManager())
    }
}
