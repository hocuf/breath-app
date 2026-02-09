//
//  ExerciseView.swift
//  breath
//
//  Created on 2025-11-19.
//

import SwiftUI

enum ExercisePhase {
    case ready
    case inhale
    case hold
    case exhale
    case rest
    case completed
}

struct ExerciseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var dataManager = DataManager.shared
    @State private var phase: ExercisePhase = .ready
    @State private var currentCycle = 0
    @State private var phaseTimeRemaining: Double = 0
    @State private var timer: Timer?
    @State private var scale: CGFloat = 1.0
    @State private var showConfig = false
    
    var exerciseConfig: ExerciseSession {
        dataManager.exerciseConfig
    }
    
    var body: some View {
        ZStack {
            // Animated Background
            AnimatedBackground(colors: backgroundColors)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("exercise_title".localized)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    
                    Spacer()
                    
                    Button(action: { showConfig = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                // Phase Indicator
                if phase != .ready && phase != .completed {
                    VStack(spacing: 12) {
                        Text(phaseText)
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(String(format: "%.0f", phaseTimeRemaining))
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .cyan],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                // Central Circle with Progress
                ZStack {
                    CircularProgress(
                        progress: progressValue,
                        color: phaseColor
                    )
                    .frame(width: 200, height: 200)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [phaseColor, phaseColor.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 150, height: 150)
                        .scaleEffect(scale)
                        .shadow(color: phaseColor.opacity(0.5), radius: 20)
                    
                    Image(systemName: phaseIcon)
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Cycle Counter
                if phase != .ready && phase != .completed {
                    Text("\("cycle_progress".localized) \(currentCycle + 1) / \(exerciseConfig.cycles)")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Start/Stop Button
                if phase == .ready {
                    VStack(spacing: 16) {
                        Text("relax_get_ready".localized)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Button(action: startExercise) {
                            Text("start".localized)
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.cyan, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(20)
                        }
                        .padding(.horizontal, 40)
                    }
                } else if phase == .completed {
                    VStack(spacing: 16) {
                        Text("🎉")
                            .font(.system(size: 60))
                        
                        Text("great_job".localized)
                            .font(.title.bold())
                        
                        Text("\(exerciseConfig.cycles) \("cycles_completed".localized)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Button(action: resetExercise) {
                            Text("restart".localized)
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.green, .teal],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(20)
                        }
                        .padding(.horizontal, 40)
                    }
                } else {
                    Button(action: stopExercise) {
                        Text("stop".localized)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(25)
                    }
                }
                
                Spacer()
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
        .sheet(isPresented: $showConfig) {
            ExerciseConfigView()
        }
    }
    
    private var phaseText: String {
        switch phase {
        case .inhale: return "inhale".localized
        case .hold: return "hold".localized
        case .exhale: return "exhale".localized
        case .rest: return "rest".localized
        default: return ""
        }
    }
    
    private var phaseIcon: String {
        switch phase {
        case .ready: return "play.circle.fill"
        case .inhale: return "arrow.down.circle.fill"
        case .hold: return "pause.circle.fill"
        case .exhale: return "arrow.up.circle.fill"
        case .rest: return "powersleep"
        case .completed: return "checkmark.circle.fill"
        }
    }
    
    private var phaseColor: Color {
        switch phase {
        case .inhale: return .cyan
        case .hold: return .blue
        case .exhale: return .mint
        case .rest: return .purple
        default: return .gray
        }
    }
    
    private var backgroundColors: [Color] {
        switch phase {
        case .inhale: return [.cyan, .blue]
        case .hold: return [.blue, .purple]
        case .exhale: return [.mint, .teal]
        case .rest: return [.purple, .pink]
        default: return [.blue, .purple]
        }
    }
    
    private var progressValue: Double {
        let totalTime: Double
        switch phase {
        case .inhale: totalTime = exerciseConfig.holdDuration
        case .hold: totalTime = exerciseConfig.holdDuration
        case .exhale: totalTime = exerciseConfig.exhaleDuration
        case .rest: totalTime = exerciseConfig.restDuration
        default: return 0
        }
        
        return 1.0 - (phaseTimeRemaining / totalTime)
    }
    
    private func startExercise() {
        currentCycle = 0
        nextPhase()
    }
    
    private func nextPhase() {
        switch phase {
        case .ready:
            phase = .inhale
            phaseTimeRemaining = exerciseConfig.holdDuration
            scale = 1.0
            startPhaseTimer()
            generateHapticFeedback(.medium)
            
        case .inhale:
            phase = .hold
            phaseTimeRemaining = exerciseConfig.holdDuration
            startPhaseTimer()
            generateHapticFeedback(.heavy)
            
        case .hold:
            phase = .exhale
            phaseTimeRemaining = exerciseConfig.exhaleDuration
            startPhaseTimer()
            generateHapticFeedback(.medium)
            
        case .exhale:
            phase = .rest
            phaseTimeRemaining = exerciseConfig.restDuration
            startPhaseTimer()
            generateHapticFeedback(.light)
            
        case .rest:
            currentCycle += 1
            if currentCycle < exerciseConfig.cycles {
                phase = .inhale
                phaseTimeRemaining = exerciseConfig.holdDuration
                scale = 1.0
                startPhaseTimer()
                generateHapticFeedback(.medium)
            } else {
                completeExercise()
            }
            
        default:
            break
        }
    }
    
    private func startPhaseTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            phaseTimeRemaining -= 0.1
            
            // Animate scale based on phase
            switch phase {
            case .inhale:
                scale = 1.0 + (0.5 * (1.0 - (phaseTimeRemaining / exerciseConfig.holdDuration)))
            case .exhale:
                scale = 1.5 - (0.5 * (1.0 - (phaseTimeRemaining / exerciseConfig.exhaleDuration)))
            case .hold:
                scale = 1.5
            case .rest:
                scale = 1.0
            default:
                break
            }
            
            if phaseTimeRemaining <= 0 {
                timer?.invalidate()
                nextPhase()
            }
        }
    }
    
    private func stopExercise() {
        timer?.invalidate()
        resetExercise()
    }
    
    private func resetExercise() {
        timer?.invalidate()
        phase = .ready
        currentCycle = 0
        phaseTimeRemaining = 0
        scale = 1.0
    }
    
    private func completeExercise() {
        timer?.invalidate()
        phase = .completed
        
        // Save exercise record
        let totalDuration = Double(exerciseConfig.cycles) * (exerciseConfig.holdDuration * 2 + exerciseConfig.exhaleDuration + exerciseConfig.restDuration)
        let record = BreathRecord(date: Date(), type: .exercise, duration: totalDuration)
        dataManager.addRecord(record)
        
        generateNotificationHaptic(.success)
    }
}

#Preview {
    ExerciseView()
}
