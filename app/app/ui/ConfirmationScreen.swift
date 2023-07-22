//
//  ConfirmationScreen.swift
//  app
//
//  Created by Jann Driessen on 21.07.23.
//

import Combine
import Foundation
import metamask_ios_sdk
import SwiftUI

struct ConfirmationScreen: View {
    let transactionManager: TransactionManager
    @State private var cancellables: Set<AnyCancellable> = []
    @State private var isPresented = false
    var body: some View {
        ZStack() {
            BlurredGradientCircle()
                .offset(x: 40, y: -60)
            VStack {
                Text("Swap \(txDetails.inputAmount) \(txDetails.inputToken) for \(txDetails.outputToken)")
                    .font(.system(size: 56))
                    .bold()
                    .padding(.top, 120)
                Spacer()
                Button("Sign&Send") {
                    isPresented = true
                }
                .buttonStyle(rounded(backgroundColor: SwapAiColor.black))
                .padding()
            }
            .padding()
        }
        .navigationBarHidden(true)
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
        ConfirmationScreen(transactionManager: TransactionManager(connectionManager: ConnectionManager()))
    }
}
