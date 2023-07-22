//
//  WalletConnectManager.swift
//  app
//
//  Created by Ümit Gül on 22.07.23.
//

import Foundation
import WalletConnectModal
import Combine

class WalletConnectManager: ObservableObject {
    
    @Published var connectedWallet: String = ""
    private var session: Session?

    
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
    
//    func listenToSessionSign() async throws {
//        let session: Session = try await withCheckedThrowingContinuation { continuation in
//            var cancellable: AnyCancellable?
//            cancellable = Sign.instance.sessionResponsePublisher
//                .receive(on: DispatchQueue.main)
//                .sink { [unowned self] response in
//                    print(response)
//                }
//        }
//    }
    
    func signData() async throws {
        guard let session else { fatalError() }
        let method = "personal_sign"
        let requestParams = AnyCodable(["0x4d7920656d61696c206973206a6f686e40646f652e636f6d202d2031363533333933373535313531", "0x462009de2bd200312aa42b8cf3e190a7f06617ad"])
        
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
