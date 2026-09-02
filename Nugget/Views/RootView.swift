//
//  ContentView.swift
//  Nugget
//
//  Created by lemin on 9/9/24.
//

import SwiftUI

struct RootView: View {
    init() {
        // Force a consistent dark appearance and gold accent for the whole app.
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor(red: 0xF0/255.0, green: 0xB9/255.0, blue: 0x0B/255.0, alpha: 1)
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
        ]
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            ToolsView()
                .tabItem {
                    Label("Tools", systemImage: "wrench.and.screwdriver.fill")
                }
        }
        .preferredColorScheme(.dark)
        .tint(GNTheme.gold)
    }
}
