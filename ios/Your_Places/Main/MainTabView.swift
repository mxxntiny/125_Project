//
//  MainTabView.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/9/26.
//

import SwiftUI

struct MainTabView: View {
    let recommendationService: RecommendationFetching
    let locationProvider: LocationProviding

    var body: some View {
        TabView {
            ExploreView(
                recommendationService: recommendationService,
                locationProvider: locationProvider
            )
            .tabItem { Label("Explore", systemImage: "map") }

            SavedView()
                .tabItem { Label("Saved", systemImage: "bookmark") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}

#Preview {
    MainTabView(
        recommendationService: RecommendationService(api: APIClient()),
        locationProvider: LocationService(manager: LocationManager())
    )
    .environmentObject(UserProfileStore())
    .environmentObject(LocationManager())
}
