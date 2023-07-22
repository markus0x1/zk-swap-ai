//
//  WalletConnectManager.swift
//  app
//
//  Created by Ümit Gül on 22.07.23.
//

import Foundation
import WalletConnectModal
import WalletConnectRelay
import Combine

struct NativeSocketFactory: WebSocketFactory {
    
    func create(with url: URL) -> WebSocketConnecting {
        return NativeSocket(withURL: url)
    }
}

class WalletConnectManager: ObservableObject {
    
    @Published var connectedWallet: String = ""
    private var session: Session?
    
    func setup() {
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
        WalletConnectModal.configure(projectId: "66e129e35de063e88a1f05631fe77edb", metadata: metadata, sessionParams: defaultSessionParams)
    }
    
    
    func listenToSession() async throws {
        let session: Session = try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = WalletConnectModal.instance.sessionSettlePublisher.sink { session in
                defer { cancellable?.cancel() }
                print(session)
                self.connectedWallet = session.accounts.first?.address ?? "no"
                self.session = session
                return continuation.resume(returning: session)
            }
        }
    }
    
    func signData() async throws {
        guard let session else { fatalError() }
        let method = "personal_sign"
        let requestParams = AnyCodable(["0x4d7920656d61696c206973206a6f686e40646f652e636f6d202d2031363533333933373535313531", "0x9c29749c5cDDa1C91ebea70D4828BcC825339B54"])
        
        let request = Request(topic: session.topic, method: method, params: requestParams, chainId: Blockchain("eip155:1")!)
        print(request)
        //        try await listenToSessionSign()
        do {
            try await Sign.instance.request(params: request)
        } catch {
            print(error.localizedDescription)
        }
    }
}
