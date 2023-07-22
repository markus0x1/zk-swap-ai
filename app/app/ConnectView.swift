//
//  ConnectView.swift
//  app
//
//  Created by Jann Driessen on 21.07.23.
//

import Combine
import SwiftUI
import WalletConnectModal

struct ConnectView: View {
    @ObservedObject private var walletConnectManager = WalletConnectManager()
    @ObservedObject private var connectionManager = ConnectionManager()
    @State private var cancellables: Set<AnyCancellable> = []
    @State private var isPresented = false
    var body: some View {
        VStack {
            Button {
                Task {
                    walletConnectManager.setup()
                    WalletConnectModal.present()
                    try await walletConnectManager.listenToSession()
                    connectionManager.connectionType = .walletconnect
                    isPresented = true
                }
            } label: {
                Image("walletConnect")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 252)
            }
            Button(action: {
                connectionManager.ethereum.connect(connectionManager.dappMetamask)?.sink(receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        print("Error connecting to Metamask: \(error.localizedDescription)")
                    default: break
                    }
                }, receiveValue: { result in
                    print("Metamask connection result: \(result)")
                    connectionManager.connectionType = .metamask
                    isPresented = true
                }).store(in: &cancellables)
            }) {
                Image("metamask")
                    .resizable()
                    .frame(width: 252, height: 80)
            }
            .padding()
        }
        .padding()
        .navigationDestination(isPresented: $isPresented) {
            RecordScreen(connectionManager: connectionManager)
        }
        .onReceive(NotificationCenter.default.publisher(for: .MetamaskConnection)) { notification in
            print(notification.userInfo?["value"] as? String ?? "Offline")
        }
    }
}

struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectView()
    }
}
