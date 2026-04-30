//
//  HomeView.swift
//  my drinks
//
//  Created by Sandy Yang on 4/29/26.
//

import SwiftUI

struct HomeView: View {
    @Binding var logs: [Log]
    @State private var showingNewLog = false
    
    var todayCaffeine: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return logs
            .filter {Calendar.current.startOfDay(for: $0.time) == today}
            .reduce(0) {$0 + $1.caffeine}
    }
    
    var thisMonthLogs: [Log] {
        let calendar = Calendar.current
        let now = Date()
        return logs.filter {
            calendar.isDate($0.time, equalTo: now, toGranularity: .month)
        }
    }
    
    var logsByDay: [(date: Date, logs: [Log])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: thisMonthLogs) {
            calendar.startOfDay(for: $0.time)
        }
        return grouped
            .map {(date: $0.key, logs: $0.value)}
            .sorted{$0.date > $1.date}
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    
                    HStack {
                        Text(Date.now.formatted(.dateTime.month(.wide)))
                            .fontWeight(.semibold)
                        Spacer()
                        Text("------------------------------------")
                    }
                    .padding(.horizontal)

                    // MARK: Caffeine Summary Card
                    VStack(alignment: .center, spacing: 10) {
                        Text("Today's Caffeine")
                            .font(.system(size: 40))
                            .fontWeight(.semibold)
                            .foregroundColor(.brown)
                        
                        Text("\(todayCaffeine) / 400 mg")
                            .font(.system(size: 30))
                            .fontWeight(.semibold)
                        Text("(Recommended limit)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .padding(.horizontal)

                        
                    // MARK: Add Button
                    Button {
                        showingNewLog = true
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add a Cup")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundColor(.white)
                        .background(.brown)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    }
                    .padding(.horizontal)
                    
                    // MARK: This Month's logs grouped by day
                    if logsByDay.isEmpty {
                        VStack(alignment: .center, spacing: 8) {
                            Text("☕")
                                .font(.system(size: 48))
                            Text("No drinks this month yet")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else {
                        ForEach(logsByDay, id: \.date) {group in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(group.date.formatted(.dateTime.month(.wide).day()))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal)
                                
                                ForEach(group.logs) {log in
                                    LogCell(log: log)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showingNewLog) {
                NewLogView(logs: $logs)
            }
        }
    }
}

#Preview {
    HomeView(logs: .constant(Log.dummyList))
}
