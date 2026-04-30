//
//  ReportView.swift
//  my drinks
//
//  Created by Sandy Yang on 4/28/26.
//

import SwiftUI

struct ReportView: View {
    let logs: [Log]
    @State private var selectedPeriod: Period = .month
    
    enum Period: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var filteredLogs: [Log] {
        let calendar = Calendar.current
        let now = Date()
        return logs.filter {
            switch selectedPeriod {
            case .week:
                return calendar.isDate($0.time, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate($0.time, equalTo: now, toGranularity: .month)
            case .year:
                return calendar.isDate($0.time, equalTo: now, toGranularity: .year)
            }
        }
    }
    
    var totalCaffeine: Int {filteredLogs.reduce(0) { $0 + $1.caffeine }}
    var totalSugar: Int {filteredLogs.reduce(0) { $0 + $1.sugar }}
    var totalSpend: Double {filteredLogs.compactMap { $0.price }.reduce(0, +) }
    var totalCups: Int { filteredLogs.count }
    
    func uniqueDays(from logs: [Log]) -> Int {
        let days = Set(logs.map {Calendar.current.startOfDay(for: $0.time)})
        return days.count
    }
    
    var dailyAvgCaffeine: Int {
        guard !filteredLogs.isEmpty else { return 0 }
        let days = uniqueDays(from : filteredLogs)
        return days == 0 ? 0 : totalCaffeine / days
    }
    
    var dailyAvgSugar: Int {
        guard !filteredLogs.isEmpty else { return 0 }
        let days = uniqueDays(from: filteredLogs)
        return days == 0 ? 0 : totalSugar / days
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // MARK: Period Picker
                    HStack(spacing: 8) {
                        ForEach(Period.allCases, id: \.self) { period in
                            Button {
                                selectedPeriod = period
                            } label: {
                                Text(period.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(selectedPeriod == period ? .semibold : .regular)
                                    .foregroundStyle(selectedPeriod == period ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedPeriod == period ? Color.brown : Color(.systemGray6))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: Type Breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("By Type")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        let typeCounts = Dictionary(grouping: filteredLogs, by: { $0.type })
                            .mapValues { $0.count }
                            .sorted { $0.value > $1.value }
                        
                        ForEach(typeCounts, id: \.key) { type, count in
                            HStack {
                                Text(type.emoji)
                                Text(type.rawValue.capitalized)
                                    .font(.subheadline)
                                Spacer()
                                Text("\(count) cups")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(.systemGray5))
                                        .frame(height: 6)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(.brown)
                                        .frame(width: geo.size.width * (totalCups == 0 ? 0 : CGFloat(count) / CGFloat(totalCups)), height: 6)
                                }
                            }
                            .frame(height: 6)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)

                    
                    // MARK: Cups + Spend
                    HStack(spacing: 16) {
                        statCard(title: "Total Cups", value: "\(totalCups)", unit: "")
                        statCard(title: "Total Spend", value: "\(totalSpend)", unit: "")
                    }
                    .padding(.horizontal)
                    
                    // MARK: Caffeine
                    HStack(spacing: 16) {
                        statCard(title: "Total Caffeine", value: "\(totalCaffeine)", unit: "mg")
                        statCard(title: "Daily Avg", value: "\(dailyAvgCaffeine)", unit: "mg")
                    }
                    .padding(.horizontal)
                    
                    // MARK: Sugar
                    HStack(spacing: 16) {
                        statCard(title: "Total Sugar", value: "\(totalSugar)", unit: "g")
                        statCard(title: "Daily Avg", value: "\(dailyAvgSugar)", unit: "g")
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // MARK: Stat Card Helper
    func statCard(title: String, value: String, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.brown)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ReportView(logs: Log.dummyList)
}
