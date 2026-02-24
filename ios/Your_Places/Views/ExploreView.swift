//
//  ContentView.swift
//  Your_Places
//
//  Created by Aidan Huerta on 1/29/26.
//
//
//

import SwiftUI
import CoreLocation

struct ExploreView: View {

    @EnvironmentObject private var profile: UserProfileStore
    @EnvironmentObject private var locationManager: LocationManager

    @StateObject private var vm: ExploreViewModel

    @State private var selectedPlace: Place? = nil

    private var userCategoryOptions: [CategoryOption] {
        profile.selectedCategoryOptions
    }

    init(recommendationService: RecommendationFetching, locationProvider: LocationProviding) {
        _vm = StateObject(
            wrappedValue: ExploreViewModel(
                recommendationService: recommendationService,
                locationProvider: locationProvider
            )
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                if let loc = locationManager.location {
                    Text("Lat: \(loc.coordinate.latitude), Lon: \(loc.coordinate.longitude)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Getting your location...")
                        .foregroundStyle(.secondary)
                }

                if let errorMessage = vm.errorMessage {
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
                                Task { await vm.didSelectCategory(option) }
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
                                            vm.selectedCategory?.id == option.id
                                            ? Color.blue.opacity(0.15)
                                            : Color.secondary.opacity(0.1)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(vm.isLoading)
                        }
                    }
                }

                if let selectedCategory = vm.selectedCategory {
                    Text("Showing results for: \(selectedCategory.title)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if vm.isLoading {
                    ProgressView("Loading recommendations...")
                        .padding(.vertical)
                }

                List(vm.places) { place in
                    Button {
                        selectedPlace = place
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(place.name ?? "Unnamed place")
                                .font(.headline)

                            Text(place.address ?? "No address available")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            // Explanation signals row
                            VStack(alignment: .leading, spacing: 2) {
                                if let d = place.distance_m {
                                    Text("Distance: \(Int(d)) m")
                                }

                                if let t = place.travel_time_s {
                                    let mins = max(1, t / 60)
                                    Text("ETA: \(mins) min")
                                }

                                if let delay = place.traffic_delay_s, delay > 0 {
                                    let mins = max(1, delay / 60)
                                    Text("Traffic delay: +\(mins) min")
                                }

                                Text("Score: \(String(format: "%.2f", place.score))")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .navigationTitle("Your Places")
            .onAppear { vm.onAppear() }
            .sheet(item: $selectedPlace) { place in
                PlaceDetailsSheet(place: place)
            }
        }
    }
}

#Preview {
    ExploreView(
        recommendationService: RecommendationService(api: APIClient()),
        locationProvider: LocationService(manager: LocationManager())
    )
    .environmentObject(UserProfileStore())
    .environmentObject(LocationManager())
}
