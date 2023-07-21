//
//  appApp.swift
//  app
//
//  Created by Jann Driessen on 21.07.23.
//

import SwiftUI

@main
struct appApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ConnectView()
            }
        }
    }
}
