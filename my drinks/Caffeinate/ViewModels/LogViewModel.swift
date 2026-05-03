//
//  LogViewModel.swift
//  my drinks
//
//  Created by Sandy Yang on 5/2/26.
//

import Foundation
import Combine

@MainActor
class LogViewModel: ObservableObject {
    @Published var logs: [Log] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // MARK: Load
    func loadLogs() async {
        await fetchLogs()
    }
    
    // MARK: Fetch
    func fetchLogs() async {
        isLoading = true
        do {
            logs = try await NetworkManager.shared.fetchLogs()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: Create
    func createLog(_ log: Log) async {
        do {
            let saved = try await NetworkManager.shared.createLog(log)
            logs.append(saved)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: Delete
    func deleteLog(id: UUID) async {
        do {
            try await NetworkManager.shared.deleteLog(id: id)
            logs.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
