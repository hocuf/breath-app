//
//  NotificationManager.swift
//  breath
//
//  Created on 2025-11-19.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @AppStorage("notificationsEnabled") var notificationsEnabled = true
    @AppStorage("notificationTimes") private var notificationTimesData: Data = Data()
    @AppStorage("notificationFrequency") var notificationFrequency = "daily" // daily, weekdays, custom
    
    var notificationTimes: [NotificationTime] {
        get {
            if let decoded = try? JSONDecoder().decode([NotificationTime].self, from: notificationTimesData) {
                return decoded
            }
            return defaultNotificationTimes
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                notificationTimesData = encoded
            }
        }
    }
    
    private var defaultNotificationTimes: [NotificationTime] {
        [
            NotificationTime(hour: 9, minute: 0, isEnabled: true),
            NotificationTime(hour: 12, minute: 0, isEnabled: true),
            NotificationTime(hour: 15, minute: 0, isEnabled: true),
            NotificationTime(hour: 18, minute: 0, isEnabled: true),
            NotificationTime(hour: 21, minute: 0, isEnabled: true)
        ]
    }
    
    private var messages: [String] {
        [
            "notif_msg_1".localized,
            "notif_msg_2".localized,
            "notif_msg_3".localized,
            "notif_msg_4".localized,
            "notif_msg_5".localized,
            "notif_msg_6".localized,
            "notif_msg_7".localized,
            "notif_msg_8".localized
        ]
    }
    
    private init() {
        checkAuthorizationStatus()
        // Initialize default times if needed
        if notificationTimesData.isEmpty {
            notificationTimes = defaultNotificationTimes
        }
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted && self.notificationsEnabled {
                    self.scheduleReminders()
                }
            }
            
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleReminders() {
        guard notificationsEnabled else { return }
        
        // Cancel existing notifications
        cancelAllNotifications()
        
        let enabledTimes = notificationTimes.filter { $0.isEnabled }
        
        for (index, time) in enabledTimes.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "notif_title".localized
            content.body = messages[index % messages.count]
            content.sound = .default
            
            var dateComponents = DateComponents()
            dateComponents.hour = time.hour
            dateComponents.minute = time.minute
            
            // Handle frequency
            switch notificationFrequency {
            case "weekdays":
                // Schedule for weekdays only (Monday-Friday)
                for weekday in 2...6 { // 1=Sunday, 2=Monday, ..., 7=Saturday
                    var weekdayComponents = dateComponents
                    weekdayComponents.weekday = weekday
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: weekdayComponents, repeats: true)
                    let request = UNNotificationRequest(
                        identifier: "reminder-\(time.hour)-\(time.minute)-\(weekday)",
                        content: content,
                        trigger: trigger
                    )
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("Error scheduling notification: \(error)")
                        }
                    }
                }
            default: // daily
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "reminder-\(time.hour)-\(time.minute)",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    }
                }
            }
        }
    }
    
    func addNotificationTime(hour: Int, minute: Int) {
        var times = notificationTimes
        times.append(NotificationTime(hour: hour, minute: minute, isEnabled: true))
        notificationTimes = times.sorted { $0.hour * 60 + $0.minute < $1.hour * 60 + $1.minute }
        scheduleReminders()
    }
    
    func removeNotificationTime(at index: Int) {
        var times = notificationTimes
        times.remove(at: index)
        notificationTimes = times
        scheduleReminders()
    }
    
    func toggleNotificationTime(at index: Int) {
        var times = notificationTimes
        times[index].isEnabled.toggle()
        notificationTimes = times
        scheduleReminders()
    }
    
    func sendTaskReminder() {
        let content = UNMutableNotificationContent()
        content.title = "notif_task_title".localized
        content.body = "notif_task_body".localized
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "task-reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending task reminder: \(error)")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

struct NotificationTime: Codable, Identifiable {
    let id: UUID
    let hour: Int
    let minute: Int
    var isEnabled: Bool
    
    init(hour: Int, minute: Int, isEnabled: Bool) {
        self.id = UUID()
        self.hour = hour
        self.minute = minute
        self.isEnabled = isEnabled
    }
    
    var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }
}
