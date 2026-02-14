//
//  Apexiel_RX_oldApp.swift
//  Apexiel_RX_old
//
//  Created by Kenji Fahselt on 2/12/26.
//

import SwiftUI

@main
struct Apexiel_RX_oldApp: App {
    var body: some Scene {
        WindowGroup {
            //ContentView()
            //DrivingView()
            MainTabView()
        }
    }
}


//mark entry and exit

struct MainTabView: View {
    var body: some View {
        TabView {
            DrivingView()       // stats
                .tabItem {
                    Label("Drive", systemImage: "car.fill")
                }

            
            RecentTurnView()            // most recent turn
                .tabItem {
                    Label("Recent", systemImage: "clock.arrow.circlepath") // unique icon
                }

            AllTurnsView()             // all turns
                .tabItem {
                    Label("Turns", systemImage: "list.bullet.rectangle") // unique icon
                }
        }
    }
}
