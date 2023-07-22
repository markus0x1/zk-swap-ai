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
                Text("Swap \n\(String(format: "%.3f", txDetails.inputAmount)) \(txDetails.inputToken) for \(txDetails.outputToken)")
                    .font(.system(size: 56))
                    .bold()
                    .padding(.top, 120)
                Spacer()
                Button("Sign&Send") {
                    isPresented = true
                    if transactionManager.connectionManager.connectionType == .metamask {
                        signWithMetamask()
                    }
                    if transactionManager.connectionManager.connectionType == .walletconnect {
                        signWithWalletConnect()
                    }
                }
                .buttonStyle(rounded(backgroundColor: SwapAiColor.black))
                .padding()
            }
            .padding()
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $isPresented) {
            SuccessScreen(transactionManager: transactionManager)
        }
    }
    private var txDetails: VoiceAnalyzerResponse {
        return transactionManager.voiceResponse ?? VoiceAnalyzerResponse(inputToken: "", outputToken: "", inputAmount: 0)
    }
}

extension ConfirmationScreen {

    private func signWithWalletConnect() {}

    private func signWithMetamask() {
        let ethereum = transactionManager.connectionManager.ethereum
        print("signWithMetamask", ethereum.connected, transactionManager.connectionManager.connectedAddress)
        let sendTxRequest = SwapApiSendTxRequest(
            safeAddress: Config.Constants.safeAddress,
            inToken: Config.Constants.WETH,
            outToken: Config.Constants.DAI,
            dx: "10000000000000000",
            minDy: "0",
            nonce: "0",
            signature: "0x000000000000000000000000000000000000dead"
        )
        guard let json = try? JSONEncoder().encode(sendTxRequest) else { return }
        let from = ethereum.selectedAddress
        let msg = json.toHexString()
        print(msg)
        let transactionRequest = EthereumRequest(
            method: .personalSign,
            params: [msg, from]
        )
        ethereum.request(transactionRequest)?.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("Error sending metamask transaction request, \(error.localizedDescription)")
            default: break
            }
        }, receiveValue: { result in
            print("/////DATA")
            print(result)
            Task.init {
                let swapApiService = SwapApiService()
                guard let res = try await swapApiService.sendTx(with: sendTxRequest) else { return }
                print("///SwapAPIResponse")
                print(res.txHash)
                print(res)
                transactionManager.outputTokenAmount = res.amountOut
                // TODO: wait for tx to finish?
                isPresented = true
            }
        })
        .store(in: &cancellables)
    }
}

struct ConfirmationScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationScreen(transactionManager: TransactionManager(connectionManager: ConnectionManager()))
    }
}
