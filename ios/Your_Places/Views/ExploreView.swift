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

    // Only one expanded at a time (dropdown feel)
    @State private var expandedCategoryID: String? = nil

    // MARK: - Data helpers

    private var allCategories: [CategoryOption] {
        CategoryCatalog.all
    }

    private var selectedSet: Set<CategoryOption> {
        Set(profile.selectedCategoryOptions)
    }

    private var unselectedCategories: [CategoryOption] {
        allCategories
            .filter { !selectedSet.contains($0) }
            .sorted { $0.title < $1.title }
    }

    private enum DayBucket {
        case morning, afternoon, evening, night
    }

    private var dayBucket: DayBucket {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<11: return .morning
        case 11..<17: return .afternoon
        case 17..<22: return .evening
        default: return .night
        }
    }

    // Titles you prefer per time bucket (edit these to match your catalog)
    private var preferredTitlesForNow: [String] {
        switch dayBucket {
        case .morning:   return ["Coffee", "Food", "Study", "Fitness"]
        case .afternoon: return ["Food", "Study", "Outdoors", "Shopping"]
        case .evening:   return ["Food", "Dessert", "Entertainment", "Outdoors"]
        case .night:     return ["Nightlife", "Dessert", "Entertainment"]
        }
    }

    // Suggested = selected categories sorted by the fixed time preference (NO user-action metric)
    private var suggestedNow: [CategoryOption] {
        let prefs = preferredTitlesForNow
        let selected = profile.selectedCategoryOptions

        let sorted = selected.sorted { a, b in
            let ia = prefs.firstIndex(of: a.title) ?? Int.max
            let ib = prefs.firstIndex(of: b.title) ?? Int.max
            if ia != ib { return ia < ib }
            return a.title < b.title
        }

        return Array(sorted.prefix(3))
    }

    private var remainingSelected: [CategoryOption] {
        let suggestedIDs = Set(suggestedNow.map { $0.id })
        return profile.selectedCategoryOptions
            .filter { !suggestedIDs.contains($0.id) }
            .sorted { $0.title < $1.title }
    }

    // MARK: - Init

    init(recommendationService: RecommendationFetching, locationProvider: LocationProviding) {
        _vm = StateObject(
            wrappedValue: ExploreViewModel(
                recommendationService: recommendationService,
                locationProvider: locationProvider
            )
        )
    }

    // MARK: - View

    var body: some View {
        NavigationStack {
            List {

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

                    if let errorMessage = vm.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                if !suggestedNow.isEmpty {
                    Section(header: Text("Suggested for you right now")) {
                        ForEach(suggestedNow) { option in
                            categoryDropdown(option, subtitle: "Suggested")
                        }
                    }
                }

                Section(header: Text("Your selected categories")) {
                    if profile.selectedCategoryOptions.isEmpty {
                        Text("No categories selected yet.")
                            .foregroundStyle(.secondary)
                    } else if remainingSelected.isEmpty {
                        Text("All of your selected categories are currently suggested above.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(remainingSelected) { option in
                            categoryDropdown(option, subtitle: nil)
                        }
                    }
                }

                Section(header: Text("More categories (not selected yet)")) {
                    if unselectedCategories.isEmpty {
                        Text("You’ve selected everything in the catalog 🎉")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(unselectedCategories) { option in
                            Button {
                                profile.addCategory(option)
                                profile.recordCategoryInteraction(title: option.title)
                            } label: {
                                HStack {
                                    Text(option.title)
                                    Spacer()
                                    Text("Add")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .disabled(vm.isLoading)
                        }
                    }
                }
            }
            .navigationTitle("Your Places")
            .onAppear { vm.onAppear() }
            .sheet(item: $selectedPlace) { place in
                PlaceDetailsSheet(place: place)
            }
        }
    }

    // MARK: - Dropdown row

    private func categoryDropdown(_ option: CategoryOption, subtitle: String?) -> some View {
        let isExpanded = Binding<Bool>(
            get: { expandedCategoryID == option.id },
            set: { newValue in
                if newValue {
                    // expand this one, collapse others
                    expandedCategoryID = option.id

                    // track user interaction
                    profile.recordCategoryInteraction(title: option.title)

                    // fetch results for this category
                    Task { await vm.didSelectCategory(option) }
                } else {
                    // collapse
                    if expandedCategoryID == option.id {
                        expandedCategoryID = nil
                    }
                }
            }
        )

        return DisclosureGroup(isExpanded: isExpanded) {
            // Children (dropdown content)
            if vm.isLoading && vm.selectedCategory?.id == option.id {
                ProgressView("Loading...")
                    .padding(.vertical, 4)
            } else if vm.selectedCategory?.id == option.id {
                if vm.places.isEmpty {
                    Text("No places found.")
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 4)
                } else {
                    ForEach(vm.places) { place in
                        Button {
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
            } else {
                // expanded, but model hasn't switched yet (rare race)
                ProgressView()
                    .padding(.vertical, 4)
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.title)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
