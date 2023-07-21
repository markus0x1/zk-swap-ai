//
//  SuccessScreen.swift
//  app
//
//  Created by Jann Driessen on 21.07.23.
//

import SwiftUI

struct SuccessScreen: View {
    var body: some View {
        VStack {
            Spacer()
            Text("You bought 0.1 ETH from UniswapV3.")
            Spacer()
            Button("Done") {}
        }
        .padding()
    }
}

struct SuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        SuccessScreen()
    }
}
