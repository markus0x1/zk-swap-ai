//
//  ConnectView.swift
//  app
//
//  Created by Jann Driessen on 21.07.23.
//

import Combine
import SwiftUI
import WalletConnectModal
import WalletConnectRelay


//extension WebSocket: WebSocketConnecting { }

struct NativeSocketFactory: WebSocketFactory {
    
    func create(with url: URL) -> WebSocketConnecting {
        return NativeSocket(withURL: url)
    }
}

struct ConnectView: View {
    
    @State var isConnected = false
    @ObservedObject private var walletConnectManager = WalletConnectManager()
//    @ObservedObject private var connectionManager = ConnectionManager()
    @State private var cancellables: Set<AnyCancellable> = []
    @State private var isPresented = false
    var body: some View {
        VStack {
            Button("SignData") {
                Task {
                    try await walletConnectManager.signData()
                }
                
            }
            Text(walletConnectManager.connectedWallet)
            Button(walletConnectManager.connectedWallet.isEmpty ? "Connect" : "Disconnect") {
                Networking.configure(projectId: "66e129e35de063e88a1f05631fe77edb", socketFactory: NativeSocketFactory())
                
                let metadata = AppMetadata(
                                    name: "Example Wallet",
                                    description: "Wallet description",
                                    url: "example.wallet",
                                    icons: ["https://avatars.githubusercontent.com/u/37784886"]
                                )
                Pair.configure(metadata: metadata)
                
                let methods: Set<String> = ["eth_sendTransaction", "personal_sign", "eth_signTypedData"]
                let events: Set<String> = ["chainChanged", "accountsChanged"]
                let blockchains: Set<Blockchain> = [Blockchain("eip155:1")!]
                let namespaces: [String: ProposalNamespace] = [
                    "eip155": ProposalNamespace(
                        chains: blockchains,
                        methods: methods,
                        events: events
                    )
                ]

                let defaultSessionParams =  SessionParams(
                                                requiredNamespaces: namespaces,
                                                optionalNamespaces: nil,
                                                sessionProperties: nil
                                            )
                WalletConnectModal.configure(projectId: "66e129e35de063e88a1f05631fe77edb", metadata: metadata,
                                             sessionParams: defaultSessionParams)
                WalletConnectModal.present()
                Task {
                    try await walletConnectManager.listenToSession()
                }
            }
        }
        .padding()
        .navigationDestination(isPresented: $isPresented) {
            RecordScreen()
        }
    }
}

struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectView()
    }
}
