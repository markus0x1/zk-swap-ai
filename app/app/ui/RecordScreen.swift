//
//  RecordScreen.swift
//  app
//
//  Created by Jann Driessen on 21.07.23.
//

import SwiftUI

struct RecordScreen: View {
    @State private var isPresented = false
    var body: some View {
        Button("TalkToMe") {
            isPresented = true
        }
        .navigationDestination(isPresented: $isPresented) {
            ConfirmationScreen()
        }
    }
}

struct RecordScreen_Previews: PreviewProvider {
    static var previews: some View {
        RecordScreen()
    }
}
