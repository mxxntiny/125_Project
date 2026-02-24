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

    private let recommendationService: RecommendationFetching =
        RecommendationService(api: APIClient())

    var body: some Scene {
        WindowGroup {
            // Create adapter using the shared manager instance
            let locationProvider: LocationProviding = LocationService(manager: locationManager)

            RootView(
                recommendationService: recommendationService,
                locationProvider: locationProvider
            )
            .environmentObject(profile)
            .environmentObject(locationManager)
        }
    }
}
