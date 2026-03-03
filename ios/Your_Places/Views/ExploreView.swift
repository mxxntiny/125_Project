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
    @EnvironmentObject private var engagement: EngagementStore

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
        CategorySuggestionPolicy.selectedPinned(from: profile.selectedCategoryOptions)
    }

    private var unselectedCategoriesRanked: [CategoryOption] {
        CategorySuggestionPolicy.unselectedRanked(
            allCategories: CategoryCatalog.all,
            selected: profile.selectedCategoryOptions,
            engagementCount: { title in
                engagement.totalInteractionCount(for: title)
            }
        )
    }

    // MARK: - UI

    var body: some View {
        NavigationStack {
            List {

                // Status
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

                // Selected (pinned + dropdown)
                Section(header: Text("Your categories")) {
                    if selectedCategoriesPinned.isEmpty {
                        Text("No categories selected yet. Add some from Suggested below.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(selectedCategoriesPinned) { option in
                            CategoryDropdownRow(
                                title: option.title,
                                isExpanded: bindingForSelected(option),
                                onExpanded: {
                                    Task { await vm.ensurePlacesLoaded(for: option) }
                                }
                            ) {
                                placesDropdownContent(for: option)
                            }
                        }
                    }
                }

                // Unselected (suggested + ranked + dropdown + add)
                Section(header: Text("Suggested")) {
                    if unselectedCategoriesRanked.isEmpty {
                        Text("You’ve selected everything in the catalog 🎉")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(unselectedCategoriesRanked) { option in
                            CategoryDropdownRow(
                                title: option.title,
                                isExpanded: bindingForUnselected(option),
                                trailingActionTitle: "Add",
                                onTrailingAction: {
                                    profile.addCategory(option)
                                    if expandedUnselectedID == option.id { expandedUnselectedID = nil }
                                },
                                onExpanded: {
                                    Task { await vm.ensurePlacesLoaded(for: option) }
                                }
                            ) {
                                placesDropdownContent(for: option)
                            }
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

    // MARK: - Bindings (dropdown state)

    private func bindingForSelected(_ option: CategoryOption) -> Binding<Bool> {
        Binding(
            get: { expandedSelectedID == option.id },
            set: { newValue in
                if newValue {
                    expandedSelectedID = option.id
                } else if expandedSelectedID == option.id {
                    expandedSelectedID = nil
                }
            }
        )
    }

    private func bindingForUnselected(_ option: CategoryOption) -> Binding<Bool> {
        Binding(
            get: { expandedUnselectedID == option.id },
            set: { newValue in
                if newValue {
                    expandedUnselectedID = option.id
                } else if expandedUnselectedID == option.id {
                    expandedUnselectedID = nil
                }
            }
        )
    }

    // MARK: - Dropdown contents

    @ViewBuilder
    private func placesDropdownContent(for option: CategoryOption) -> some View {
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
                        // Engagement should be counted on meaningful action (place tap).
                        engagement.recordEngagement(categoryTitle: option.title)
                        selectedPlace = place
                    } label: {
                        PlaceRow(place: place)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
