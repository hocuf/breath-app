//
//  AddNotificationTimeView.swift
//  breath
//
//  Created on 2025-11-25.
//

import SwiftUI

struct AddNotificationTimeView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var notificationManager = NotificationManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedHour = 12
    @State private var selectedMinute = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "bell.badge.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("new_reminder".localized)
                                .font(.title2.bold())
                        }
                        .padding(.vertical)
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
                
                Section("select_time".localized) {
                    HStack {
                        Spacer()
                        
                        // Hour Picker
                        Picker("Saat", selection: $selectedHour) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text(String(format: "%02d", hour))
                                    .tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80)
                        .clipped()
                        
                        Text(":")
                            .font(.title.bold())
                        
                        // Minute Picker
                        Picker("Dakika", selection: $selectedMinute) {
                            ForEach([0, 15, 30, 45], id: \.self) { minute in
                                Text(String(format: "%02d", minute))
                                    .tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80)
                        .clipped()
                        
                        Spacer()
                    }
                }
                
                Section {
                    Button(action: {
                        notificationManager.addNotificationTime(hour: selectedHour, minute: selectedMinute)
                        presentationMode.wrappedValue.dismiss()
                        generateNotificationHaptic(.success)
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                            Text("add".localized)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("add_reminder".localized)
            .navigationBarTitleDisplayMode(.inline)
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
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    AddNotificationTimeView()
}
