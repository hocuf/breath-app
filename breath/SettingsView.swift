//
//  SettingsView.swift
//  breath
//
//  Created on 2025-11-19.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var notificationManager = NotificationManager.shared
    @ObservedObject private var dataManager = DataManager.shared
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [.gray.opacity(0.1), .gray.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                List {

                    // Appearance Section
                    Section("appearance".localized) {
                        Toggle(isOn: $isDarkMode) {
                            HStack {
                                Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                                    .foregroundColor(isDarkMode ? .purple : .orange)
                                Text("dark_mode".localized)
                           }
                        }
                        
                        // Language Picker
                        Picker("language".localized, selection: $localizationManager.selectedLanguage) {
                            Text("language_turkish".localized).tag("tr")
                            Text("language_english".localized).tag("en")
                        }
                    }
                    
                    // Notifications Section
                    Section {
                        // Notification Master Toggle
                        Toggle(isOn: $notificationManager.notificationsEnabled) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.blue)
                                Text("notifications".localized)
                            }
                        }
                        .onChange(of: notificationManager.notificationsEnabled) { enabled in
                            if enabled && notificationManager.isAuthorized {
                                notificationManager.scheduleReminders()
                            } else if !enabled {
                                notificationManager.cancelAllNotifications()
                            }
                        }
                        
                        if !notificationManager.isAuthorized {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("permission_required".localized)
                                
                                Spacer()
                                
                                Button("grant_permission".localized) {
                                    notificationManager.requestPermission()
                                }
                                .buttonStyle(.bordered)
                                .tint(.blue)
                            }
                        }
                        
                        if notificationManager.notificationsEnabled && notificationManager.isAuthorized {
                            // Frequency Picker
                            Picker("frequency".localized, selection: $notificationManager.notificationFrequency) {
                                Text("daily".localized).tag("daily")
                                Text("weekdays".localized).tag("weekdays")
                            }
                            .onChange(of: notificationManager.notificationFrequency) { _ in
                                notificationManager.scheduleReminders()
                            }
                            
                            // Notification Times
                            ForEach(Array(notificationManager.notificationTimes.enumerated()), id: \.element.id) { index, time in
                                HStack {
                                    Toggle(isOn: Binding(
                                        get: { time.isEnabled },
                                        set: { _ in notificationManager.toggleNotificationTime(at: index) }
                                    )) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "clock.fill")
                                                .foregroundColor(time.isEnabled ? .blue : .gray)
                                            
                                            Text(time.timeString)
                                                .font(.headline)
                                                .foregroundColor(time.isEnabled ? .primary : .secondary)
                                        }
                                    }
                                    
                                    Button(action: {
                                        notificationManager.removeNotificationTime(at: index)
                                    }) {
                                        Image(systemName: "trash.fill")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                            
                            // Add New Time Button
                            NavigationLink(destination: AddNotificationTimeView()) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.green)
                                    Text("add_new_time".localized)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    } header: {
                        Text("notification_settings".localized)
                    } footer: {
                        if notificationManager.notificationsEnabled && notificationManager.isAuthorized {
                            Text("notification_footer".localized)
                        }
                    }
                    
                    // Daily Tasks Section
                    Section("daily_tasks".localized) {
                        ForEach(dataManager.dailyTasks) { task in
                            HStack {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(task.isCompleted ? .green : .secondary)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(task.localizedTitle)
                                        .font(.subheadline)
                                    
                                    ProgressView(value: task.progress)
                                        .tint(task.isCompleted ? .green : .blue)
                                }
                                
                                Spacer()
                                
                                Text("\(task.current)/\(task.target)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Stats Section
                    Section("statistics".localized) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.purple)
                            Text("total_records".localized)
                            Spacer()
                            Text("\(dataManager.records.count)")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            Text("today_sessions".localized)
                            Spacer()
                            Text("\(dataManager.recordsForToday().count)")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Data Section
                    Section("data_management".localized) {
                        Button(role: .destructive, action: {
                            showResetAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("delete_all_data".localized)
                            }
                        }
                    }
                    
                    // About Section
                    Section("about".localized) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("version".localized)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }
                    }
                }

            }
            .navigationTitle("settings_title".localized)
            .alert("delete_all".localized, isPresented: $showResetAlert) {
                Button("cancel".localized, role: .cancel) { }
                Button("delete".localized, role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("delete_message".localized)
            }
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    private func resetAllData() {
        dataManager.records.removeAll()
        dataManager.dailyTasks.removeAll()
        dataManager.saveRecordsLocally()
        dataManager.saveTasksLocally()
        
        generateHapticFeedback(.heavy)
    }
}

#Preview {
    SettingsView()
}
