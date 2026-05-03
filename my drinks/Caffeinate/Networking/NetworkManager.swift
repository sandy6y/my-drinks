//
//  NetworkManager.swift
//  my drinks
//
//  Created by Sandy Yang on 4/28/26.
//

import Foundation

// MARK: - Drinks app errors

enum NetworkError: LocalizedError {
    case invalidURL
    case encodingFailed
    case noData
    case decodingFailed(Error)
    case serverError(Int)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .encodingFailed: return "Failed to encode request body."
        case .noData: return "No data received from server."
        case .decodingFailed(let e): return "Decoding failed: \(e.localizedDescription)"
        case .serverError(let code): return "Server returned status \(code)."
        case .unknown(let e): return e.localizedDescription
        }
    }
}

// MARK: - Drinks app (placeholder backend)

final class NetworkManager {
    static let shared = NetworkManager()

    private init() {}

    private let drinksBaseURL = "https://caffeinate-backend.onrender.com"

    func fetchLogs() async throws -> [Log] {
        guard let url = URL(string: "\(drinksBaseURL)/v1/logs") else { throw NetworkError.invalidURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        try validateDrinks(response: response)

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Log].self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    func createLog(_ log: Log) async throws -> Log {
        guard let url = URL(string: "\(drinksBaseURL)/v1/logs") else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
       
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let body = try? encoder.encode(log) else { throw NetworkError.encodingFailed }
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateDrinks(response: response)

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Log.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    func deleteLog(id: UUID) async throws {
        guard let url = URL(string: "\(drinksBaseURL)/v1/logs/\(id.uuidString)") else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (_, response) = try await URLSession.shared.data(for: request)
        try validateDrinks(response: response)
    }

    private func validateDrinks(response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.serverError(http.statusCode)
        }
    }
}
