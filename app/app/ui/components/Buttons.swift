//
//  Buttons.swift
//  app
//
//  Created by Jann Driessen on 22.07.23.
//

import SwiftUI

struct rounded: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    var backgroundColor: Color

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .bold()
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .background(backgroundColor)
            .cornerRadius(26.0)
            .shadow(color: Color.black.opacity(0.5), radius: 3, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .frame(height: 52)
    }
}
