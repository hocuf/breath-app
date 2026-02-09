//
//  TrainingView.swift
//  breath
//
//  Created on 2025-11-19.
//

import SwiftUI

struct TrainingView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedMode: Int? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [.cyan.opacity(0.3), .blue.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 8) {
                            Text("training_title".localized)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                            
                            Text("training_subtitle".localized)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 30)
                        .padding(.bottom, 20)
                        
                        // Mode Cards
                        NavigationLink(
                            destination: HoldBreathView().navigationBarTitleDisplayMode(.inline),
                            tag: 0,
                            selection: $selectedMode
                        ) {
                            EmptyView()
                        }
                        .frame(width: 0, height: 0)
                        .hidden()
                        
                        TrainingModeCard(
                            title: "mode_hold".localized,
                            subtitle: "mode_hold_subtitle".localized,
                            icon: "wind",
                            colors: [.cyan, .blue],
                            emoji: "🫁"
                        ) {
                            selectedMode = 0
                        }
                        
                        NavigationLink(
                            destination: ExhaleBreathView().navigationBarTitleDisplayMode(.inline),
                            tag: 1,
                            selection: $selectedMode
                        ) {
                            EmptyView()
                        }
                        .frame(width: 0, height: 0)
                        .hidden()
                        
                        TrainingModeCard(
                            title: "mode_exhale".localized,
                            subtitle: "mode_exhale_subtitle".localized,
                            icon: "wind.snow",
                            colors: [.mint, .teal],
                            emoji: "🌬️"
                        ) {
                            selectedMode = 1
                        }
                        
                        NavigationLink(
                            destination: ExerciseView().navigationBarTitleDisplayMode(.inline),
                            tag: 2,
                            selection: $selectedMode
                        ) {
                            EmptyView()
                        }
                        .frame(width: 0, height: 0)
                        .hidden()
                        
                        TrainingModeCard(
                            title: "mode_exercise".localized,
                            subtitle: "mode_exercise_subtitle".localized,
                            icon: "figure.mind.and.body",
                            colors: [.purple, .pink],
                            emoji: "🧘‍♂️"
                        ) {
                            selectedMode = 2
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct TrainingModeCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let colors: [Color]
    let emoji: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Icon Circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .shadow(color: colors.first!.opacity(0.4), radius: 10)
                    
                    Text(emoji)
                        .font(.system(size: 35))
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TrainingView()
}
