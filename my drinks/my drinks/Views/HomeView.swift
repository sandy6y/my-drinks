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
    @State private var selectedMonth: Date = Date()
    
    // MARK: Navigation
    func goBack() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
    }
    
    func goForward() {
        let next = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
        if !Calendar.current.isDate(next, equalTo: Date(), toGranularity: .month) && next > Date() {
            return
        }
        selectedMonth = next
    }
    
    var isCurrentMonth: Bool {
        Calendar.current.isDate(selectedMonth, equalTo: Date(), toGranularity: .month)
    }
    
    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }
    
    // MARK: Computation
    var todayCaffeine: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return logs
            .filter {Calendar.current.startOfDay(for: $0.time) == today}
            .reduce(0) {$0 + $1.caffeine}
    }
    
    var thisMonthLogs: [Log] {
        return logs.filter {
            Calendar.current.isDate($0.time, equalTo: selectedMonth, toGranularity: .month)
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
                    
                    // MARK: Month Navigator
                    
                    HStack {
                        Button {
                            goBack()
                        } label: {
                            Image(systemName: "chevron.left")
                                .fontWeight(.semibold)
                                .foregroundStyle(.brown)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Text(monthTitle)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button {
                            goForward()
                        } label: {
                            Image(systemName: "chevron.right")
                                .fontWeight(.semibold)
                                .foregroundStyle(.brown)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                        .disabled(isCurrentMonth)
                    }
                    .padding(.horizontal)

                    // MARK: Caffeine Summary Card
                    // only show today's caffeine with logs of current month
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
                    .frame(maxWidth: .infinity)
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
                    
                    // MARK: Logs grouped by day
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
