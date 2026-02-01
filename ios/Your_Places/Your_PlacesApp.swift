//
//  Your_PlacesApp.swift
//  Your_Places
//
//  Created by Aidan Huerta on 1/29/26.
//



/* This file is the entry point of the application.
// It is responsible for:
// - Defining where the app starts
// - Creating the main app window
// - Choosing the initial view shown to the user
//
// You should modify this file ONLY when:
// - Changing the initial/root view
// - Injecting app-wide shared objects (e.g. LocationManager, APIClient)
// - Supporting multiple windows or scenes
//
// This file should NOT contain:
// - Business logic
// - Networking code
// - Location or permission logic
//
// Keep this file focused on app startup and configuration only.
*/

import SwiftUI
// SwiftUI is Apple’s framework for building user interfaces

// @main tells iOS: "This is the entry point of the app"
@main
struct Your_PlacesApp: App {
    
    // The body defines the scenes (windows) this app provides
    var body: some Scene {
        
        // WindowGroup creates the main app window
        // (supports multiple windows on iPad/macOS if needed)
        WindowGroup {
            
            // ContentView is the first screen shown to the user
            ContentView()
        }
    }
}
