//
//  Your_PlacesApp.swift
//  Your_Places
//
//  Created by Aidan Huerta on 1/29/26.
//
//
//  Your_PlacesApp.swift
//  Your_Places
//
//  Entry point of the application.
//  Refactor: create shared app-wide objects once and inject them via environment.
//

import SwiftUI

@main
struct YourPlacesApp: App {

    @StateObject private var profile = UserProfileStore()
    @StateObject private var locationManager = LocationManager()

    // Simple injection: build the service at app start
    private let recommendationService: RecommendationFetching =
        RecommendationService(api: APIClient())

    var body: some Scene {
        WindowGroup {
            RootView(recommendationService: recommendationService)
                .environmentObject(profile)
                .environmentObject(locationManager)
        }
    }
}
