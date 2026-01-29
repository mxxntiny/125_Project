//
//  ContentView.swift
//  Your_Places
//
//  Created by Aidan Huerta on 1/29/26.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    private let api = APIClient()

    @State private var places: [Place] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                if let loc = locationManager.location {
                    Text("Lat: \(loc.coordinate.latitude), Lon: \(loc.coordinate.longitude)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Location not available yet")
                        .foregroundStyle(.secondary)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }

                Button(isLoading ? "Loading..." : "Get Recommendations") {
                    Task { await loadRecommendations() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading || locationManager.location == nil)

                List(places) { place in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(place.name ?? "Unnamed place")
                            .font(.headline)
                        Text(place.address ?? "No address")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if let d = place.distance_m {
                            Text("Distance: \(Int(d)) m  •  Score: \(String(format: "%.2f", place.score))")
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
                // Ask for location once UI loads
                locationManager.requestLocation()
            }
        }
    }

    @MainActor
    private func loadRecommendations() async {
        errorMessage = nil
        guard let loc = locationManager.location else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            places = try await api.fetchRecommendations(
                lat: loc.coordinate.latitude,
                lon: loc.coordinate.longitude
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// Preview provider to display the ContentView in Xcode's preview window
#Preview {
    ContentView()
}
