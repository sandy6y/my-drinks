//
//  ProfileView.swift
//  my drinks
//
//  Created by Sandy Yang on 4/29/26.
//

import SwiftUI

struct ProfileView: View {
    let logs: [Log]
    
    // MARK: All Time Stats
    var totalCups: Int { logs.count }
    var totalCaffeine: Int { logs.reduce(0) {$0 + $1.caffeine} }
    var totalSugar: Int { logs.reduce(0) {$0 + $1.sugar}}
    var totalSpend: Double { logs.compactMap {$0.price}.reduce(0, +) }
    var favoriteDrinkType: DrinkType? {
        let counts = Dictionary(grouping: logs, by: { $0.type }).mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key
    }
    var joinedDate: Date { logs.map { $0.time }.min() ?? Date() }
    
    // MARK: Personal Records
    var mostCaffeinatedDay: (date: Date, amount: Int)? {
        guard !logs.isEmpty else { return nil }
        let grouped = Dictionary(grouping: logs) {
            Calendar.current.startOfDay(for: $0.time)
        }
        let dailyTotals = grouped.mapValues { $0.reduce(0) {$0 + $1.caffeine} }
        guard let best = dailyTotals.max(by: {$0.value < $1.value}) else { return nil }
        return (date: best.key, amount: best.value)
    }
    
    var mostSweetDay: (date: Date, amount: Int)? {
        guard !logs.isEmpty else { return nil }
        let grouped = Dictionary(grouping: logs) {
            Calendar.current.startOfDay(for: $0.time)
        }
        let dailyTotals = grouped.mapValues { $0.reduce(0) {$0 + $1.sugar} }
        guard let best = dailyTotals.max(by: {$0.value < $1.value}) else { return nil }
        return (date: best.key, amount: best.value)
    }
    
    var mostExpensiveDrink: Log? {
        logs.filter { $0.price != nil }.max(by: { ($0.price ?? 0) < ($1.price ?? 0)})
    }
    
    var hotVsIced: String {
        let iced = logs.filter { $0.temperature == .iced }.count
        let hot = logs.filter { $0.temperature == .hot }.count
        if iced == hot { return "🧊 Iced AND Hot person 🔥"}
        return iced > hot ? "🧊 Iced person" : "🔥 Hot person"
    }
    
    var avgSpend: Double {
        let priced = logs.compactMap { $0.price }
        guard !priced.isEmpty else { return 0 }
        return priced.reduce(0, +) / Double(priced.count)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: Identity Card
                    VStack(spacing: 12) {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text("☕️")
                                    .font(.system(size: 36))
                            )
                        Text("Username")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Member since \(joinedDate.formatted(.dateTime.month(.wide).year()))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if let fav = favoriteDrinkType {
                            HStack(spacing: 6) {
                                Text("🏆")
                                Text("Favorite:")
                                    .foregroundStyle(.secondary)
                                Text(fav.rawValue.capitalized)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.brown)
                                Text(fav.emoji)
                            }
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.brown.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // MARK: All Time Stats
                    sectionHeader("All Time")
                    
                    HStack(spacing: 16) {
                        statCard(icon: "cup.and.saucer.fill", title: "Total Cups", value: "\(totalCups)")
                        statCard(icon: "bolt.fill", title: "Total Caffeine", value: "\(totalCaffeine) mg")
                        statCard(icon: "cube.fill", title: "Total Sugar", value: "\(totalSugar) g")

                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        statCard(icon: "dollarsign", title: "Total Spent", value: String(format: "$%.2f", totalSpend))
                        statCard(icon: "dollarsign.circle", title: "Avg Per Cup", value: String(format: "$%.2f", avgSpend))
                    }
                    .padding(.horizontal)
                    
                    // MARK: Taste Profile
                    sectionHeader("Taste Profile")
                    
                    HStack(spacing: 16) {
                        statCard(icon: "thermometer.medium", title: "You're a", value: hotVsIced)
                    }
                    .padding(.horizontal)
                    
                    // MARK: Personal Records
                    sectionHeader("Personal Records")
                    
                    VStack(spacing: 12) {
                        if let best = mostCaffeinatedDay {
                            recordRow(
                                emoji: "⚡",
                                title: "Most Caffeinated Day",
                                value: "\(best.amount) mg · \(best.date.formatted(.dateTime.month(.abbreviated).day()))"
                            )
                            Divider()
                        }
                        
                        if let sweet = mostSweetDay {
                            recordRow(
                                emoji: "🍬",
                                title: "Most Sugar Day",
                                value: "\(sweet.amount) g · \(sweet.date.formatted(.dateTime.month(.abbreviated).day()))"
                            )
                            Divider()
                        }
                        
                        if let expensive = mostExpensiveDrink {
                            recordRow(
                                emoji: "💸",
                                title: "Most Expensive",
                                value: "\(expensive.name.isEmpty ? expensive.type.rawValue.capitalized : expensive.name) · \(String(format: "$%.2f", expensive.price ?? 0))"
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // MARK: Helpers
    func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 4)
    }
    
    func statCard(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.brown)
                .font(.title3)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
    
    func recordRow(emoji: String, title: String, value: String) -> some View {
        HStack {
            Text(emoji)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            Spacer()
        }
    }
}

#Preview {
    ProfileView(logs: Log.dummyList)
}
