//
//  Log.swift
//  my drinks
//
//  Created by Sandy Yang on 4/28/26.
//

import Foundation

struct Log: Identifiable, Codable {
    var id: UUID = UUID()
    let name: String
    let time: Date
    let type: DrinkType
    let size: DrinkSize
    let temperature: DrinkTemperature
    let caffeine: Int
    let sugar: Int
    let price: Double?
    let rating: Int?
    let note: String?
}

enum DrinkTemperature: String, Codable, CaseIterable {
    case hot, iced
}

enum DrinkType: String, Codable, CaseIterable {
    case espresso, americano, latte, mocha, flatWhite, cappuccino, matcha, tea, boba, energydrink, other
    
    var emoji: String {
        switch self {
        case .espresso: return "☕️"
        case .americano: return "🥃"
        case .latte: return "🥛"
        case .cappuccino: return "☁️"
        case .flatWhite: return "⬜️"
        case .mocha: return "🍫"
        case .matcha: return "🍵"
        case .tea: return "🫖"
        case .boba: return "🧋"
        case .energydrink: return "⚡️"
        case .other: return "➕"
        }
    }
}

enum DrinkSize: String, Codable, CaseIterable {
    case small, medium, large, XL
}

extension Log {
    static let dummy = Log(
        name: "Pistachio Cloud Jasmine",
        time: Date(),
        type: .boba,
        size: .medium,
        temperature: .iced,
        caffeine: 156,
        sugar: 20,
        price: 7.50,
        rating: 5,
        note: "So good!"
    )
    
    
    static let dummyList: [Log] = [
        Log(name: "Pistachio Cloud Jasmine", time: Date.from(year: 2026, month: 3, day: 20), type: .boba, size: .medium, temperature: .iced, caffeine: 156, sugar: 20, price: 7.50, rating: 5, note: nil),
        Log(name: "Vanilla Latte", time: Date.from(year: 2026, month: 4, day: 20), type: .latte, size: .medium, temperature: .iced, caffeine: 75, sugar: 10, price: 6.00, rating: 3, note: nil),
        Log(name: "", time: Date.from(year: 2025, month: 12, day: 25), type: .espresso, size: .small, temperature: .hot, caffeine: 64, sugar: 0, price: nil, rating: nil, note: nil),
        Log(name: "Matcha", time: Date.from(year: 2026, month: 4, day: 20), type: .other, size: .large, temperature: .iced, caffeine: 0, sugar: 5, price: 5.50, rating: 2, note: "Too sweet"),
        Log(name: "Cappuccino", time: Date.from(year: 2026, month: 4, day: 21), type: .cappuccino, size: .medium, temperature: .hot, caffeine: 75, sugar: 0, price: 4.50, rating: 4, note: nil),
        Log(name: "Cappuccino", time: Date.from(year: 2026, month: 4, day: 22), type: .cappuccino, size: .medium, temperature: .hot, caffeine: 75, sugar: 0, price: 4.50, rating: 4, note: nil)
    ]
    
    static let dummyEmptyList: [Log] = []
}
