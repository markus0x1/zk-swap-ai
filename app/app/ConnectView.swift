//
//  ConnectView.swift
//  app
//
//  Created by Jann Driessen on 21.07.23.
//

import SwiftUI
import WalletConnectModal

struct ConnectView: View {
    @State private var isPresented = false
    var body: some View {
        VStack {
            Button("Connect") {
                isPresented = true
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
