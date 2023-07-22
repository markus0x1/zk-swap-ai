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
        do {
            // TODO: only forward once tx is done?
            // TODO: pass tx information (to display on next screen)?
            
            let ethereum = transactionManager.connectionManager.ethereum
            print("signAndSend", ethereum.connected, transactionManager.connectionManager.connectedAddress)
            
            // Create parameters
            //                let parameters: [String: String] = [
            //                    "to": "0x...", // receiver address
            //                    "from": ethereum.selectedAddress, // sender address
            //                    "value": "0x..." // amount
            //                  ]
            //
            //                let signV4Params: [String: [String: String]] = [
            //                    "domain": [
            //                        "chainId": "5",
            //                        "name": "SwapAI",
            //                        "verifyingContract": "",
            //                        "version": "1"
            //                    ],
            //                    "message": [
            //                        //                "from": "0xb386B8923434D9DAF9C97AF35afEDea3C93160bF"
            //                        "safe": "0xCe79d02774B7432E023122D9189D295d189B1cc8",
            //                        "inToken": "0x1684F4DF5e32a946fBbaEb3059353c83Ff075E31", // WETH
            //                        "outToken": "0xDAFA240382BE6e8Fb5b13D1516d3d220Cf5A1622", // DAI
            //                        "dx": "10000000000000000",
            ////         don't send this
            //                        "minDy": "9900000000000000"
            //    ]
            //                ]
            
            // Create request
            //        let transactionRequest = EthereumRequest(
            //            method: .ethSendTransaction,
            //            params: [parameters] // eth_sendTransaction expects an array parameters object
            //            )
            
            // Create request
            //                        let transactionRequest = EthereumRequest(
            //                            method: .ethSignTypedDataV4,
            //                            // TODO: get address: 0xb386B8923434D9DAF9C97AF35afEDea3C93160bF
            //                            params: [signV4Params]
            //                        )
            //
            
            let from = "0xb386B8923434D9DAF9C97AF35afEDea3C93160bF"
            let msg = "0xb386B8923434D9DAF9C97AF35afEDea3C93160bF"
            let transactionRequest = EthereumRequest(
                method: .personalSign,
                // TODO: get address: 0xb386B8923434D9DAF9C97AF35afEDea3C93160bF
                params: [msg, from]
            )
            
            
            // Make a transaction request
            ethereum.request(transactionRequest)?.sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error sending transaction request, \(error.localizedDescription)")
                default: break
                }
            }, receiveValue: { result in
                print("/////DATA")
                // TODO: send to API
                print(result)
                Task.init {
                    let swapApiService = SwapApiService()
                    let sendTxRequest = SwapApiSendTxRequest(
                        safeAddress: Config.Constants.safeAddress,
                        inToken: Config.Constants.WETH,
                        outToken: Config.Constants.DAI,
                        dx: "10000000000000000",
                        minDy: "0",
                        nonce: "0",
                        signature: "0x000000000000000000000000000000000000dead"
                    )
                    let res = try await swapApiService.sendTx(with: sendTxRequest)
                    print(res)
                }
                // TODO: get tx.hash in return?
                // TODO: wait for tx to finish?
            })
            .store(in: &cancellables)
            
            //TODO:
            isPresented = true
        } catch {
            print("Error sending tx", error)
        }
    }
}

struct ConfirmationScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationScreen(transactionManager: TransactionManager(connectionManager: ConnectionManager()))
    }
}

