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

    // Shared singletons for the whole app session
    @StateObject private var profile = UserProfileStore()
    @StateObject private var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(profile)
                .environmentObject(locationManager)
        }
    }
}
