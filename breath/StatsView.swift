//
//  StatsView.swift
//  breath
//
//  Created on 2025-11-19.
//

import SwiftUI

struct StatsView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var dataManager = DataManager.shared
    @State private var selectedTimeframe: Timeframe = .week
    
    enum Timeframe: String, CaseIterable {
        case today, week, month
        
        var displayName: String {
            switch self {
            case .today: return "timeframe_today".localized
            case .week: return "timeframe_week".localized
            case .month: return "timeframe_month".localized
            }
        }
    }
    
    var timeframeRecords: [BreathRecord] {
        switch selectedTimeframe {
        case .today: return dataManager.recordsForToday()
        case .week: return dataManager.recordsForWeek()
        case .month: return dataManager.recordsForMonth()
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [.purple.opacity(0.1), .pink.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Timeframe Picker
                        Picker("Zaman Aralığı", selection: $selectedTimeframe) {
                            ForEach(Timeframe.allCases, id: \.self) { timeframe in
                                Text(timeframe.displayName).tag(timeframe)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Summary Cards
                        LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
                            StatCard(
                                title: "Toplam Seans",
                                value: "\(timeframeRecords.count)",
                                icon: "flame.fill",
                                color: .orange
                            )
                            
                            StatCard(
                                title: "Toplam Süre",
                                value: "\(Int(totalDuration))s",
                                icon: "timer",
                                color: .blue
                            )
                            
                            StatCard(
                                title: "En İyi Tutma",
                                value: bestHold,
                                icon: "trophy.fill",
                                color: .yellow
                            )
                            
                            StatCard(
                                title: "Ortalama",
                                value: "\(Int(averageDuration))s",
                                icon: "chart.bar.fill",
                                color: .green
                            )
                        }
                        .padding(.horizontal)
                        
                        // Chart
                        if !timeframeRecords.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("performance_chart".localized)
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                // Simple Bar Chart
                                VStack(spacing: 16) {
                                    ForEach(chartData) { item in
                                        HStack(spacing: 12) {
                                            Text(item.type.rawValue)
                                                .font(.subheadline)
                                                .frame(width: 80, alignment: .leading)
                                            
                                            GeometryReader { geometry in
                                                ZStack(alignment: .leading) {
                                                    // Background
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .fill(Color.gray.opacity(0.2))
                                                        .frame(height: 20)
                                                    
                                                    // Bar
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .fill(
                                                            LinearGradient(
                                                                colors: item.colors,
                                                                startPoint: .leading,
                                                                endPoint: .trailing
                                                            )
                                                        )
                                                        .frame(
                                                            width: max(30, geometry.size.width * CGFloat(item.average / maxAverage)),
                                                            height: 20
                                                        )
                                                }
                                            }
                                            .frame(height: 20)
                                            
                                            Text(String(format: "%.1fs", item.average))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .frame(width: 50, alignment: .trailing)
                                        }
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.ultraThinMaterial)
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // Best Scores
                        VStack(alignment: .leading, spacing: 12) {
                            Text("best_scores".localized)
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                BestScoreRow(
                                    type: .hold,
                                    record: dataManager.bestScore(for: .hold),
                                    color: .blue
                                )
                                
                                BestScoreRow(
                                    type: .exhale,
                                    record: dataManager.bestScore(for: .exhale),
                                    color: .teal
                                )
                                
                                BestScoreRow(
                                    type: .exercise,
                                    record: dataManager.bestScore(for: .exercise),
                                    color: .purple
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("stats_title".localized)
        }
        .navigationViewStyle(.stack)
    }
    
    private var totalDuration: Double {
        timeframeRecords.map { $0.duration }.reduce(0, +)
    }
    
    private var averageDuration: Double {
        guard !timeframeRecords.isEmpty else { return 0 }
        return totalDuration / Double(timeframeRecords.count)
    }
    
    private var bestHold: String {
        let best = timeframeRecords.filter { $0.type == .hold }.max { $0.duration < $1.duration }
        return best != nil ? "\(String(format: "%.1f", best!.duration))s" : "-"
    }
    
    private struct ChartDataItem: Identifiable {
        let id = UUID()
        let type: BreathType
        let average: Double
        let colors: [Color]
    }
    
    private var chartData: [ChartDataItem] {
        BreathType.allCases.compactMap { type in
            let records = timeframeRecords.filter { $0.type == type }
            guard !records.isEmpty else { return nil }
            
            let avg = records.map { $0.duration }.reduce(0, +) / Double(records.count)
            let colors: [Color] = {
                switch type {
                case .hold: return [.cyan, .blue]
                case .exhale: return [.mint, .teal]
                case .exercise: return [.purple, .pink]
                }
            }()
            
            return ChartDataItem(type: type, average: avg, colors: colors)
        }
    }
    
    private var maxAverage: Double {
        chartData.map { $0.average }.max() ?? 1.0
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title.bold())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

struct BestScoreRow: View {
    let type: BreathType
    let record: BreathRecord?
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: type.icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(type.rawValue)
                .font(.headline)
            
            Spacer()
            
            if let record = record {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(String(format: "%.1f", record.duration))s")
                        .font(.title3.bold())
                        .foregroundColor(color)
                    
                    Text(record.scoreLevel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("-")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    StatsView()
}
