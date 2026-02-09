//
//  HistoryView.swift
//  breath
//
//  Created on 2025-11-19.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var dataManager = DataManager.shared
    @State private var selectedFilter: BreathType? = nil
    
    var filteredRecords: [BreathRecord] {
        if let filter = selectedFilter {
            return dataManager.records.filter { $0.type == filter }
        }
        return dataManager.records
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(title: "filter_all".localized, isSelected: selectedFilter == nil) {
                                selectedFilter = nil
                            }
                            
                            ForEach(BreathType.allCases, id: \.self) { type in
                                FilterChip(
                                    title: type.displayName,
                                    isSelected: selectedFilter == type
                                ) {
                                    selectedFilter = type
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .background(.ultraThinMaterial)
                    
                    // Records List
                    if filteredRecords.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "wind")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            
                            Text("no_records".localized)
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            Text("no_records_subtitle".localized)
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(groupedRecords.keys.sorted(by: >), id: \.self) { date in
                                Section(header: Text(formatSectionDate(date))) {
                                    ForEach(groupedRecords[date] ?? []) { record in
                                        HistoryRow(record: record)
                                    }
                                }
                            }
                        }
                        .listStyle(.insetGrouped)

                    }
                }
            }
            .navigationTitle("history_title".localized)
        }
        .navigationViewStyle(.stack)
    }
    
    private var groupedRecords: [String: [BreathRecord]] {
        Dictionary(grouping: filteredRecords) { record in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: record.date)
        }
    }
    
    private func formatSectionDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: dateString) else {
            return dateString
        }
        
        if Calendar.current.isDateInToday(date) {
            return "today".localized
        } else if Calendar.current.isDateInYesterday(date) {
            return "yesterday".localized
        } else {
            dateFormatter.dateFormat = "d MMMM yyyy"
            return dateFormatter.string(from: date)
        }
    }
}

struct HistoryRow: View {
    let record: BreathRecord
    
    var body: some View {
        HStack(spacing: 16) {
            // Type Icon
            Image(systemName: record.type.icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.type.displayName)
                    .font(.headline)
                
                Text(formatTime(record.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.1fs", record.duration))
                    .font(.title3.bold())
                    .foregroundColor(iconColor)
                
                HStack(spacing: 4) {
                    Text(record.scoreLevel)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(record.scoreLevelEmoji)
                        .font(.caption2)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var iconColor: Color {
        switch record.type {
        case .hold: return .blue
        case .exhale: return .teal
        case .exercise: return .purple
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ?
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [.gray.opacity(0.2)], startPoint: .leading, endPoint: .trailing)
                        )
                )
        }
    }
}

#Preview {
    HistoryView()
}
