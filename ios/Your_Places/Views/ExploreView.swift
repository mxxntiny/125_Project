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

    // One expanded at a time per section
    @State private var expandedSelectedID: String? = nil
    @State private var expandedUnselectedID: String? = nil

    init(recommendationService: RecommendationFetching, locationProvider: LocationProviding) {
        _vm = StateObject(
            wrappedValue: ExploreViewModel(
                recommendationService: recommendationService,
                locationProvider: locationProvider
            )
        )
    }

    // MARK: - Lists

    private var selectedCategoriesPinned: [CategoryOption] {
        // Pinned + stable ordering
        profile.selectedCategoryOptions.sorted { $0.title < $1.title }
    }

    private var unselectedCategoriesRanked: [CategoryOption] {
        let selectedSet = Set(profile.selectedCategoryOptions)
        let unselected = CategoryCatalog.all.filter { !selectedSet.contains($0) }

        // Rank ONLY unselected categories by past interactions
        return unselected.sorted { a, b in
            let ca = profile.totalInteractionCount(for: a.title)
            let cb = profile.totalInteractionCount(for: b.title)
            if ca != cb { return ca > cb }
            return a.title < b.title
        }
    }

    // MARK: - UI

    var body: some View {
        NavigationStack {
            List {

                // Optional status
                Section {
                    if let loc = locationManager.location {
                        Text("Lat: \(loc.coordinate.latitude), Lon: \(loc.coordinate.longitude)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Getting your location...")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    if let err = vm.errorMessage {
                        Text(err)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                // SELECTED (pinned + dropdown)
                Section(header: Text("Your categories")) {
                    if selectedCategoriesPinned.isEmpty {
                        Text("No categories selected yet. Add some from Suggested below.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(selectedCategoriesPinned) { option in
                            selectedDropdownRow(option)
                        }
                    }
                }

                // UNSELECTED (suggested + ranked + dropdown + add)
                Section(header: Text("Suggested")) {
                    if unselectedCategoriesRanked.isEmpty {
                        Text("You’ve selected everything in the catalog 🎉")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(unselectedCategoriesRanked) { option in
                            unselectedDropdownRow(option)
                        }
                    }
                }
            }
            .navigationTitle("Explore")
            .onAppear { vm.onAppear() }
            .sheet(item: $selectedPlace) { place in
                PlaceDetailsSheet(place: place)
            }
        }
    }

    // MARK: - Selected dropdown row (NO add button)

    private func selectedDropdownRow(_ option: CategoryOption) -> some View {
        let isExpanded = Binding<Bool>(
            get: { expandedSelectedID == option.id },
            set: { newValue in
                if newValue {
                    expandedSelectedID = option.id
                    // optional: close unselected dropdown if you want only one open total
                    // expandedUnselectedID = nil
                    Task { await vm.ensurePlacesLoaded(for: option) }
                } else {
                    if expandedSelectedID == option.id { expandedSelectedID = nil }
                }
            }
        )

        return DisclosureGroup(isExpanded: isExpanded) {
            dropdownPlaces(for: option)
        } label: {
            Text(option.title)
        }
    }

    // MARK: - Unselected dropdown row (with Add)

    private func unselectedDropdownRow(_ option: CategoryOption) -> some View {
        let isExpanded = Binding<Bool>(
            get: { expandedUnselectedID == option.id },
            set: { newValue in
                if newValue {
                    expandedUnselectedID = option.id
                    // optional: close selected dropdown if you want only one open total
                    // expandedSelectedID = nil
                    Task { await vm.ensurePlacesLoaded(for: option) }
                } else {
                    if expandedUnselectedID == option.id { expandedUnselectedID = nil }
                }
            }
        )

        return DisclosureGroup(isExpanded: isExpanded) {
            dropdownPlaces(for: option)
        } label: {
            HStack {
                Text(option.title)
                Spacer()

                Button {
                    profile.addCategory(option)
                    // Collapse after adding (clean)
                    if expandedUnselectedID == option.id { expandedUnselectedID = nil }
                } label: {
                    Text("Add")
                        .font(.footnote)
                }
                .controlSize(.small)
                .buttonStyle(.borderless) // prevents toggling DisclosureGroup when tapping Add
            }
        }
    }

    // MARK: - Shared dropdown content

    private func dropdownPlaces(for option: CategoryOption) -> some View {
        Group {
            if vm.loadingCategoryID == option.id {
                ProgressView("Loading...")
                    .padding(.vertical, 4)
            } else {
                let places = vm.placesByCategoryID[option.id] ?? []

                if places.isEmpty {
                    Text("No places found.")
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 4)
                } else {
                    ForEach(places) { place in
                        Button {
                            // Count engagement on PLACE tap (stable UX; doesn’t reshuffle on expand)
                            profile.recordRecommendationEngagement(categoryTitle: option.title)
                            selectedPlace = place
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(place.name ?? "Unnamed place")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text(place.address ?? "No address available")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
