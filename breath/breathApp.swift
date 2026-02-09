//
//  breathApp.swift
//  breath
//
//  Created on 2025-11-19.
//

import SwiftUI

@main
struct breathApp: App {
    @StateObject private var dataManager = DataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

