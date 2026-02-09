//
//  DataManager.swift
//  breath
//
//  Created on 2025-11-19.
//

import Foundation

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var records: [BreathRecord] = []
    @Published var dailyTasks: [DailyTask] = []
    @Published var exerciseConfig: ExerciseSession = ExerciseSession()
    
    private let recordsFileName = "breath_records.json"
    private let tasksFileName = "daily_tasks.json"
    private let configFileName = "exercise_config.json"
    
    private init() {
        loadRecords()
        loadTasks()
        loadExerciseConfig()
        generateDailyTasksIfNeeded()
    }
    
    // MARK: - File URLs
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var recordsURL: URL {
        getDocumentsDirectory().appendingPathComponent(recordsFileName)
    }
    
    private var tasksURL: URL {
        getDocumentsDirectory().appendingPathComponent(tasksFileName)
    }
    
    private var configURL: URL {
        getDocumentsDirectory().appendingPathComponent(configFileName)
    }
    
    // MARK: - Records Management
    
    func addRecord(_ record: BreathRecord) {
        records.insert(record, at: 0)
        saveRecords()
        updateTaskProgress(for: record)
    }
    
    func saveRecordsLocally() {
        do {
            let data = try JSONEncoder().encode(records)
            try data.write(to: recordsURL)
        } catch {
            print("Error saving records: \(error)")
        }
    }
    
    private func saveRecords() {
        saveRecordsLocally()
    }
    
    private func loadRecords() {
        guard FileManager.default.fileExists(atPath: recordsURL.path) else {
            records = []
            return
        }
        
        do {
            let data = try Data(contentsOf: recordsURL)
            records = try JSONDecoder().decode([BreathRecord].self, from: data)
        } catch {
            print("Error loading records: \(error)")
            records = []
        }
    }
    
    // MARK: - Tasks Management
    
    private func generateDailyTasksIfNeeded() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if we have tasks for today
        let todayTasks = dailyTasks.filter { calendar.isDate($0.date, inSameDayAs: today) }
        
        if todayTasks.isEmpty {
            // Generate new tasks for today
            dailyTasks = [
                DailyTask(title: "task_hold_3", target: 3, current: 0, type: .hold, date: today),
                DailyTask(title: "task_exhale_5", target: 5, current: 0, type: .exhale, date: today),
                DailyTask(title: "task_exercise_2", target: 2, current: 0, type: .exercise, date: today)
            ]
            saveTasks()
        }
    }
    
    private func updateTaskProgress(for record: BreathRecord) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        for index in dailyTasks.indices {
            if calendar.isDate(dailyTasks[index].date, inSameDayAs: today),
               dailyTasks[index].type == record.type,
               !dailyTasks[index].isCompleted {
                dailyTasks[index].current += 1
                saveTasks()
                break
            }
        }
    }
    
    func saveTasksLocally() {
        do {
            let data = try JSONEncoder().encode(dailyTasks)
            try data.write(to: tasksURL)
        } catch {
            print("Error saving tasks: \(error)")
        }
    }
    
    private func saveTasks() {
        saveTasksLocally()
    }
    
    private func loadTasks() {
        guard FileManager.default.fileExists(atPath: tasksURL.path) else {
            dailyTasks = []
            return
        }
        
        do {
            let data = try Data(contentsOf: tasksURL)
            dailyTasks = try JSONDecoder().decode([DailyTask].self, from: data)
        } catch {
            print("Error loading tasks: \(error)")
            dailyTasks = []
        }
    }
    
    // MARK: - Exercise Config
    
    func saveExerciseConfig() {
        do {
            let data = try JSONEncoder().encode(exerciseConfig)
            try data.write(to: configURL)
        } catch {
            print("Error saving config: \(error)")
        }
    }
    
    private func loadExerciseConfig() {
        guard FileManager.default.fileExists(atPath: configURL.path) else {
            exerciseConfig = ExerciseSession()
            return
        }
        
        do {
            let data = try Data(contentsOf: configURL)
            exerciseConfig = try JSONDecoder().decode(ExerciseSession.self, from: data)
        } catch {
            print("Error loading config: \(error)")
            exerciseConfig = ExerciseSession()
        }
    }
    
    // MARK: - Statistics
    
    func recordsForToday() -> [BreathRecord] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return records.filter { calendar.isDate($0.date, inSameDayAs: today) }
    }
    
    func recordsForWeek() -> [BreathRecord] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        return records.filter { $0.date >= weekAgo }
    }
    
    func recordsForMonth() -> [BreathRecord] {
        let calendar = Calendar.current
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: Date())!
        return records.filter { $0.date >= monthAgo }
    }
    
    func averageDuration(for type: BreathType, in timeframe: [BreathRecord]) -> Double {
        let filtered = timeframe.filter { $0.type == type }
        guard !filtered.isEmpty else { return 0 }
        return filtered.map { $0.duration }.reduce(0, +) / Double(filtered.count)
    }
    
    func bestScore(for type: BreathType) -> BreathRecord? {
        records.filter { $0.type == type }.max { $0.duration < $1.duration }
    }
}
