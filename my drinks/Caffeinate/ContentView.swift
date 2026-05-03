//
//  ContentView.swift
//  my drinks
//
//  Created by Sandy Yang on 4/28/26.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject var viewModel = LogViewModel()

    var body: some View {
        TabView {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "cup.and.saucer.fill")
                }
            ReportView(logs: viewModel.logs)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                }
            ProfileView(logs: viewModel.logs)
                .tabItem {
                    Image(systemName: "person.fill")
                }
        }
        .tint(.brown)
        .task {
            await viewModel.fetchLogs()
        }
    }
}

#Preview {
    ContentView()
}
