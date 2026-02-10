//
//  MainTabView.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/9/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ExploreView()
                .tabItem { Label("Explore", systemImage: "map") }

            SavedView()
                .tabItem { Label("Saved", systemImage: "bookmark") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}
