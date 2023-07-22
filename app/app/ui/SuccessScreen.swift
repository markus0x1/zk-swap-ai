//
//  SuccessScreen.swift
//  app
//
//  Created by Jann Driessen on 21.07.23.
//

import SwiftUI

struct SuccessScreen: View {
    let transactionManager: TransactionManager
    var body: some View {
        ZStack() {
            BlurredGradientCircle()
                .offset(x: 40, y: -60)
            VStack(alignment: .center) {
                Text("You bought\n\(transactionManager.outputTokenAmount) \(transactionManager.outputTokenSymbol) from UniswapV3.")
                    .font(.system(size: 48))
                    .bold()
                    .padding(.top, 120)
                Spacer()
                Button("Done") {}
                    .buttonStyle(rounded(backgroundColor: SwapAiColor.black))
                    .padding()
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}

struct BlurredGradientCircle: View {
    var body: some View {
        ZStack {
            // Create a gradient
            RadialGradient(
                gradient: Gradient(colors: [Color.purple, Color.blue, Color.orange]),
                center: .topTrailing,
                startRadius: 20,
                endRadius: 200
            )
            // Apply a blur effect
            .blur(radius: 50) // Adjust the blur radius as needed
        }
        // Use an appropriate size for the circle
        .frame(width: 400, height: 200)
        .opacity(0.4)
    }
}
