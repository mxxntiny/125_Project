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
import CoreLocation

// A simple model that represents one category shown to the user
struct CategoryOption: Identifiable {
    let id = UUID()
    let title: String                  // Text shown in the UI
    let geoapifyCategories: [String]   // Categories sent to the backend
}

// ContentView defines the main screen of the app
struct ContentView: View {

    // Manages location permissions and GPS updates
    @StateObject private var locationManager = LocationManager()

    // Handles all communication with the backend
    private let api = APIClient()

    // Stores the list of places returned from the backend
    @State private var places: [Place] = []

    // Tracks whether a backend request is in progress
    @State private var isLoading = false

    // Stores an error message to display if something goes wrong
    @State private var errorMessage: String?

    // Tracks which category the user selected
    @State private var selectedCategory: CategoryOption?

    // Top categories shown to the user (mocked for now)
    // Later this can be generated dynamically based on user context
    private let topCategoryOptions: [CategoryOption] = [
        CategoryOption(title: "Cafes Near You", geoapifyCategories: ["catering.cafe"]),
        CategoryOption(title: "Popular Restaurants", geoapifyCategories: ["catering.restaurant"]),
        CategoryOption(title: "Coffee & Food", geoapifyCategories: ["catering.cafe", "catering.restaurant"]),
        CategoryOption(title: "Parks to Relax", geoapifyCategories: ["leisure.park"])
    ]

    // Defines the UI layout
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {

                // Show the user's location status
                if let loc = locationManager.location {
                    Text("Lat: \(loc.coordinate.latitude), Lon: \(loc.coordinate.longitude)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Getting your location...")
                        .foregroundStyle(.secondary)
                }

                // Show an error message if something fails
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }

                // Header for the category section
                Text("Top Categories for You")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Vertical list of category options
                VStack(spacing: 8) {
                    ForEach(topCategoryOptions) { option in
                        Button {
                            // Save selected category
                            selectedCategory = option

                            // Load recommendations for this category
                            Task { await loadRecommendations(for: option) }
                        } label: {
                            HStack {
                                Text(option.title)

                                Spacer()

                                // Indicates tapping this leads to results
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        selectedCategory?.id == option.id
                                        ? Color.blue.opacity(0.15)
                                        : Color.secondary.opacity(0.1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(isLoading || locationManager.location == nil)
                    }
                }

                // Show which category is currently active
                if let selectedCategory {
                    Text("Showing results for: \(selectedCategory.title)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Show loading indicator while fetching data
                if isLoading {
                    ProgressView("Loading recommendations...")
                        .padding(.vertical)
                }

                // List of places returned from the backend
                List(places) { place in
                    VStack(alignment: .leading, spacing: 4) {

                        Text(place.name ?? "Unnamed place")
                            .font(.headline)

                        Text(place.address ?? "No address available")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if let d = place.distance_m {
                            Text("Distance: \(Int(d)) m • Score: \(String(format: "%.2f", place.score))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Score: \(String(format: "%.2f", place.score))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Your Places")

            // Request location access when the screen appears
            .onAppear {
                locationManager.requestLocation()
            }
        }
    }

    // Fetch recommendations for a selected category
    @MainActor
    private func loadRecommendations(for option: CategoryOption) async {

        // Clear previous errors
        errorMessage = nil

        // Ensure location is available
        guard let loc = locationManager.location else { return }

        // Show loading state
        isLoading = true
        defer { isLoading = false }

        do {
            // Call backend with user location and selected category
            places = try await api.fetchRecommendations(
                lat: loc.coordinate.latitude,
                lon: loc.coordinate.longitude,
                categories: option.geoapifyCategories
            )
        } catch {
            // Display any error that occurs
            errorMessage = error.localizedDescription
        }
    }
}

// Preview for Xcode canvas
#Preview {
    ContentView()
}
