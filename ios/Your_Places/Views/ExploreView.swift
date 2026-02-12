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

struct ExploreView: View {

    // ✅ Use the profile store (same as onboarding)
    @StateObject private var profile = UserProfileStore()

    @StateObject private var locationManager = LocationManager()
    private let api = APIClient()

    @State private var places: [Place] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedCategory: CategoryOption?

    // Pull selected categories directly from profile
    private var userCategoryOptions: [CategoryOption] {
        profile.selectedCategoryOptions
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                // Location display
                if let loc = locationManager.location {
                    Text("Lat: \(loc.coordinate.latitude), Lon: \(loc.coordinate.longitude)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Getting your location...")
                        .foregroundStyle(.secondary)
                }

                // Error display
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }

                Text("Your Selected Categories")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 8) {
                    if userCategoryOptions.isEmpty {
                        Text("No categories selected yet.")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        ForEach(userCategoryOptions) { option in
                            Button {
                                selectedCategory = option
                                Task { await loadRecommendations(for: option) }
                            } label: {
                                HStack {
                                    Text(option.title)
                                    Spacer()
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
                }

                if let selectedCategory {
                    Text("Showing results for: \(selectedCategory.title)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if isLoading {
                    ProgressView("Loading recommendations...")
                        .padding(.vertical)
                }

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
            .onAppear {
                locationManager.requestLocation()
            }
        }
    }

    @MainActor
    private func loadRecommendations(for option: CategoryOption) async {
        errorMessage = nil
        guard let loc = locationManager.location else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            places = try await api.fetchRecommendations(
                lat: loc.coordinate.latitude,
                lon: loc.coordinate.longitude,
                categories: option.geoapifyCategories   // REAL backend keys
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ExploreView()
}
