//
//  ContentView.swift
//  breath
//
//  Created on 2025-11-19.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var dataManager = DataManager.shared
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        TabView {
            // Training Tab with 3 modes
            TrainingView()
                .tabItem {
                    Label("tab_training".localized, systemImage: "figure.mind.and.body")
                }
            
            // History Tab
            HistoryView()
                .tabItem {
                    Label("tab_history".localized, systemImage: "clock.fill")
                }
            
            // Statistics Tab
            StatsView()
                .tabItem {
                    Label("tab_stats".localized, systemImage: "chart.bar.fill")
                }
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("tab_settings".localized, systemImage: "gearshape.fill")
                }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
}
