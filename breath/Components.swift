//
//  Components.swift
//  breath
//
//  Created on 2025-11-19.
//

import SwiftUI

// MARK: - Animated Background
struct AnimatedBackground: View {
    @State private var animate = false
    let colors: [Color]
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 300, height: 300)
                    .offset(x: animate ? CGFloat.random(in: -50...50) : CGFloat.random(in: -30...30),
                            y: animate ? CGFloat.random(in: -50...50) : CGFloat.random(in: -30...30))
                    .blur(radius: 60)
                    .opacity(0.6)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 3...5))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.5),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Breath Button
struct BreathButton: View {
    let scale: CGFloat
    let isPressed: Bool
    let breathType: BreathType
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: breathType == .hold
                            ? [Color.cyan, Color.blue, Color.purple]
                            : [Color.mint, Color.teal, Color.cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 150, height: 150)
                .scaleEffect(scale)
                .shadow(color: breathType == .hold ? .blue.opacity(0.5) : .teal.opacity(0.5),
                        radius: isPressed ? 30 : 10)
            
            Image(systemName: breathType == .hold ? "lungs.fill" : "wind")
                .font(.system(size: 50))
                .foregroundColor(.white)
                .scaleEffect(scale)
        }
    }
}

// MARK: - Result Card
struct ResultCard: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    let duration: Double
    let record: BreathRecord
    let onDismiss: () -> Void
    
    @State private var showConfetti = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(record.scoreLevelEmoji)
                .font(.system(size: 80))
                .scaleEffect(showConfetti ? 1.2 : 0.8)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showConfetti)
            
            VStack(spacing: 8) {
                Text("\(String(format: "%.1f", duration)) \("seconds".localized)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text(record.scoreLevel)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            Button(action: onDismiss) {
                Text("continue".localized)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
            }
            .padding(.horizontal)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
        )
        .padding(40)
        .onAppear {
            showConfetti = true
            generateNotificationHaptic(.success)
        }
    }
}

// MARK: - Circular Progress
struct CircularProgress: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 10)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [color, color.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
    }
}

// MARK: - Haptic Feedback Helper
func generateHapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
}

func generateNotificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(type)
}
