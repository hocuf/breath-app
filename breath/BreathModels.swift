//
//  BreathModels.swift
//  breath
//
//  Created on 2025-11-19.
//

import Foundation

enum BreathType: String, Codable, CaseIterable {
    case hold = "Hold"
    case exhale = "Exhale"
    case exercise = "Exercise"
    
    var icon: String {
        switch self {
        case .hold: return "wind"
        case .exhale: return "wind.snow"
        case .exercise: return "figure.mind.and.body"
        }
    }
    
    var displayName: String {
        switch self {
        case .hold: return "breath_hold".localized
        case .exhale: return "breath_exhale".localized
        case .exercise: return "breath_exercise".localized
        }
    }
}

struct BreathRecord: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var type: BreathType
    var duration: Double
    
    var scoreLevel: String {
        switch duration {
        case 0..<10:
            return "score_weak".localized
        case 10..<20:
            return "score_improving".localized
        case 20..<30:
            return "score_good".localized
        case 30..<45:
            return "score_swimmer".localized
        case 45..<60:
            return "score_excellent".localized
        default:
            return "score_diver".localized
        }
    }
    
    var scoreLevelEmoji: String {
        switch duration {
        case 0..<10:
            return "😮‍💨"
        case 10..<20:
            return "💪"
        case 20..<30:
            return "🔥"
        case 30..<45:
            return "🏊‍♂️"
        case 45..<60:
            return "⭐️"
        default:
            return "🤿"
        }
    }
}

struct DailyTask: Identifiable, Codable {
    var id = UUID()
    var title: String
    var target: Int
    var current: Int
    var type: BreathType?
    var date: Date
    
    var isCompleted: Bool {
        current >= target
    }
    
    var progress: Double {
        min(Double(current) / Double(target), 1.0)
    }
    
    var localizedTitle: String {
        // Title is now stored as a localization key, so we localize it
        return title.localized
    }
}

struct ExerciseSession: Codable {
    var holdDuration: Double = 4.0
    var exhaleDuration: Double = 6.0
    var restDuration: Double = 2.0
    var cycles: Int = 5
}
