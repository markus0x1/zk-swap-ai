//
//  ConnectionManager.swift
//  app
//
//  Created by Jann Driessen on 22.07.23.
//

import Combine
import Foundation
import metamask_ios_sdk
import SwiftUI

extension Notification.Name {
    static let MetamaskEvent = Notification.Name("event")
    static let MetamaskConnection = Notification.Name("connection")
}

class ConnectionManager: ObservableObject {
    // MetaMask
    let dappMetamask = Dapp(name: "swap.ai", url: "https://swap.ai")
    @ObservedObject var ethereum = MetaMaskSDK.shared.ethereum

    var connectedAddress: String {
        return ethereum.selectedAddress
    }

    init() {
        ethereum.clearSession()
        ethereum.disconnect()
        print("METASMASK.connected", ethereum.connected)
    }
}
