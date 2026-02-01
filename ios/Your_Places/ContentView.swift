//
//  ContentView.swift
//  Your_Places
//
//  Created by Aidan Huerta on 1/29/26.
//


/* This file defines the main user interface of the app.
// It is responsible for:
// - Requesting the user’s location when the view appears
// - Triggering backend API calls based on user interaction
// - Managing loading, error, and result states
// - Displaying recommended places returned from the backend
//
// You should modify this file when:
// - Changing the UI layout or user interaction flow
// - Adjusting when or how API requests are triggered
// - Adding filters, buttons, or user-driven controls
//
// This file should NOT contain:
// - Location permission or GPS logic (LocationManager)
// - Networking or request-building logic (APIClient)
// - Data decoding or backend response definitions (Place)
//
// Keep this file focused on UI and app flow orchestration.
*/


import SwiftUI
// SwiftUI is Apple’s framework for building UI declaratively

import CoreLocation
// Needed because we use CLLocation types (latitude / longitude)


// ContentView defines the main screen of the app
struct ContentView: View {
    
    // @StateObject means SwiftUI owns this object
    // and keeps it alive while the view exists
    
    @StateObject private var locationManager = LocationManager()
    
    // APIClient handles communication with the backend
    private let api = APIClient()

    // Stores the list of places returned by the backend
    @State private var places: [Place] = []
    
    // Tracks whether a request is currently in progress
    @State private var isLoading = false
    
    // Stores an error message to show in the UI (if any)
    @State private var errorMessage: String?

    
    // The UI layout for this screen
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                
                // Show the user’s coordinates if location is available
                if let loc = locationManager.location {
                    Text("Lat: \(loc.coordinate.latitude), Lon: \(loc.coordinate.longitude)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                else {
                    // Shown while location is still being retrieved

                    Text("Location not available yet")
                        .foregroundStyle(.secondary)
                }

                // Display an error message if something went wrong
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
                
    

                // Button that triggers backend request
                Button(isLoading ? "Loading..." : "Get Recommendations") {
                    
                    // Task runs async code from a button tap
                    Task { await loadRecommendations() }
                }
                .buttonStyle(.borderedProminent)
                
                // Disable button if loading or location is missing
                .disabled(isLoading || locationManager.location == nil)

                
                // Display the list of places
                List(places) { place in
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        // Place name
                        Text(place.name ?? "Unnamed place")
                            .font(.headline)
                        
                        // Place address
                        Text(place.address ?? "No address")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        // Distance + score (if distance exists)
                        if let d = place.distance_m {
                            Text("Distance: \(Int(d)) m  •  Score: \(String(format: "%.2f", place.score))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        else {
                            Text("Score: \(String(format: "%.2f", place.score))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Your Places")
            
            // Runs when the view appears on screen
            .onAppear {
                // Ask for location once UI loads
                locationManager.requestLocation()
            }
        }
    }
    
    
    
    // Ensures UI updates happen on the main thread
    @MainActor
    private func loadRecommendations() async {
        
        // Clear previous error
        errorMessage = nil
        
        // Make sure we have a valid location
        guard let loc = locationManager.location else { return }

        
        // Show loading state
        isLoading = true
        
        // Ensure loading state is turned off when function exits
        defer { isLoading = false }

        do {
            // Call the backend using the user’s coordinates
            places = try await api.fetchRecommendations(
                lat: loc.coordinate.latitude,
                lon: loc.coordinate.longitude
            )
        } catch {
            
            // Show any error that occurs
            errorMessage = error.localizedDescription
        }
    }
}

// Preview provider to display the ContentView in Xcode's preview window
#Preview {
    ContentView()
}
