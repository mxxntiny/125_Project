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

    private var userCategoryOptions: [CategoryOption] {
        profile.selectedCategoryOptions
    }

    init(recommendationService: RecommendationFetching) {
        _vm = StateObject(wrappedValue: ExploreViewModel(recommendationService: recommendationService))
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
                                vm.selectCategory(option)

                                guard let loc = locationManager.location else { return }
                                Task {
                                    await vm.loadRecommendations(
                                        for: option,
                                        coordinate: loc.coordinate
                                    )
                                }
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
                            .disabled(vm.isLoading || locationManager.location == nil)
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
}

#Preview {
    ExploreView(recommendationService: RecommendationService(api: APIClient()))
        .environmentObject(UserProfileStore())
        .environmentObject(LocationManager())
}
