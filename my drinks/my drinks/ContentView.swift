//
//  ContentView.swift
//  my drinks
//
//  Created by Sandy Yang on 4/28/26.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var logs: [Log] = Log.dummyList
    
    var body: some View {        
        TabView {
            HomeView(logs: $logs)
                .tabItem {
                    Image(systemName: "cup.and.saucer.fill")
                }
            ReportView(logs: logs)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                }
            ProfileView(logs: logs)
                .tabItem {
                    Image(systemName: "person.fill")
                }
        }
        .tint(.brown)
    }
}

#Preview {
    ContentView()
}
