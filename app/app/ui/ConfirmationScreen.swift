//
//  ConfirmationScreen.swift
//  app
//
//  Created by Jann Driessen on 21.07.23.
//

import SwiftUI

struct ConfirmationScreen: View {
    @State private var isPresented = false
    var body: some View {
        VStack {
            Spacer()
            Button("Sign&Send") {
                isPresented = true
            }
        }
        .padding()
        .navigationDestination(isPresented: $isPresented) {
            SuccessScreen()
        }
    }
}

struct ConfirmationScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationScreen()
    }
}
