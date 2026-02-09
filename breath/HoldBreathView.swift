//
//  HoldBreathView.swift
//  breath
//
//  Created on 2025-11-19.
//

import SwiftUI

struct HoldBreathView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var dataManager = DataManager.shared
    @State private var isHolding = false
    @State private var duration: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var timer: Timer?
    @State private var showResult = false
    @State private var lastRecord: BreathRecord?
    
    let maxScale: CGFloat = 2.5
    let maxDuration: Double = 120.0
    
    var body: some View {
        ZStack {
            // Animated Background
            AnimatedBackground(colors: [.cyan, .blue, .purple, .pink])
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Title
                if !isHolding && !showResult {
                    VStack(spacing: 8) {
                        Text("hold_title".localized)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                        Text("hold_subtitle".localized)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 40)
                    .transition(.opacity)
                }
                
                // Timer Display (while holding)
                if isHolding {
                    Text(String(format: "%.1f", duration))
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .cyan],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                // Breath Button with Gesture
                ZStack {
                    BreathButton(scale: scale, isPressed: isHolding, breathType: .hold)
                    
                    // Invisible overlay for gesture detection
                    Circle()
                        .fill(.clear)
                        .frame(width: 200, height: 200)
                        .contentShape(Circle())
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    if !isHolding {
                                        startHolding()
                                    }
                                }
                                .onEnded { _ in
                                    stopHolding()
                                }
                        )
                }
                
                Spacer()
                
                // Instructions
                if !isHolding && !showResult {
                    Text("hold_instruction".localized)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 40)
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isHolding)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showResult)
            
            // Result Overlay
            if showResult, let record = lastRecord {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                ResultCard(duration: duration, record: record) {
                    withAnimation {
                        showResult = false
                        duration = 0
                        scale = 1.0
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                        Text("back".localized)
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func startHolding() {
        guard !isHolding else { return }
        
        isHolding = true
        duration = 0
        generateHapticFeedback(.light)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            duration += 0.1
            
            // Update scale based on duration
            let progress = min(duration / maxDuration, 1.0)
            scale = 1.0 + (progress * (maxScale - 1.0))
            
            // Haptic feedback at milestones
            if duration.truncatingRemainder(dividingBy: 10.0) < 0.15 && duration > 1 {
                if duration < 20 {
                    generateHapticFeedback(.medium)
                } else if duration < 30 {
                    generateHapticFeedback(.heavy)
                } else {
                    generateNotificationHaptic(.success)
                }
            }
        }
    }
    
    private func stopHolding() {
        guard isHolding else { return }
        
        timer?.invalidate()
        timer = nil
        isHolding = false
        
        // Create and save record
        let record = BreathRecord(date: Date(), type: .hold, duration: duration)
        dataManager.addRecord(record)
        lastRecord = record
        
        // Show result
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showResult = true
            scale = 1.0
        }
        
        generateNotificationHaptic(.success)
    }
}

#Preview {
    HoldBreathView()
}
