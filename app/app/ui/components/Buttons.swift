//
//  Buttons.swift
//  app
//
//  Created by Jann Driessen on 22.07.23.
//

import SwiftUI

struct GlowingButton: View {
    @Binding var isTalking: Bool
    @State private var isGlowing = false
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(fillColor)
                .shadow(color: fillColor.opacity(0.8), radius: isGlowing ? 30 : 0)
            Text(isTalking ? "Listening..." : "TalkToMe")
                .foregroundColor(.white)
        }
        .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true))
        .frame(width: 200, height: 64)
        .onAppear {
            self.isGlowing = true
        }
    }
    private var fillColor: Color {
        return SwapAiColor.black
    }
}

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
