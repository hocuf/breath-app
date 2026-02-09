//
//  ExerciseConfigView.swift
//  breath
//
//  Created on 2025-11-19.
//

import SwiftUI

struct ExerciseConfigView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var holdDuration: Double
    @State private var exhaleDuration: Double
    @State private var restDuration: Double
    @State private var cycles: Double
    
    init() {
        let config = DataManager.shared.exerciseConfig
        _holdDuration = State(initialValue: config.holdDuration)
        _exhaleDuration = State(initialValue: config.exhaleDuration)
        _restDuration = State(initialValue: config.restDuration)
        _cycles = State(initialValue: Double(config.cycles))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("hold_duration".localized) {
                    HStack {
                        Text("\(Int(holdDuration)) \("seconds".localized)")
                            .foregroundColor(.secondary)
                        Spacer()
                        Slider(value: $holdDuration, in: 2...30, step: 1)
                            .frame(width: 200)
                    }
                }
                
                Section("exhale_duration".localized) {
                    HStack {
                        Text("\(Int(exhaleDuration)) \("seconds".localized)")
                            .foregroundColor(.secondary)
                        Spacer()
                        Slider(value: $exhaleDuration, in: 2...30, step: 1)
                            .frame(width: 200)
                    }
                }
                
                Section("rest_duration".localized) {
                    HStack {
                        Text("\(Int(restDuration)) \("seconds".localized)")
                            .foregroundColor(.secondary)
                        Spacer()
                        Slider(value: $restDuration, in: 1...10, step: 1)
                            .frame(width: 200)
                    }
                }
                
                Section("cycle_count".localized) {
                    HStack {
                        Text("\(Int(cycles)) \("cycles".localized)")
                            .foregroundColor(.secondary)
                        Spacer()
                        Slider(value: $cycles, in: 1...20, step: 1)
                            .frame(width: 200)
                    }
                }
                
                Section {
                    let totalTime = Int(cycles) * (Int(holdDuration) * 2 + Int(exhaleDuration) + Int(restDuration))
                    Text("\("config_total_duration".localized) ~\(totalTime / 60) \("minutes".localized) \(totalTime % 60) \("seconds".localized)")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("exercise_settings".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("save".localized) {
                        saveConfig()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveConfig() {
        dataManager.exerciseConfig = ExerciseSession(
            holdDuration: holdDuration,
            exhaleDuration: exhaleDuration,
            restDuration: restDuration,
            cycles: Int(cycles)
        )
        dataManager.saveExerciseConfig()
    }
}

#Preview {
    ExerciseConfigView()
}
