//
//  ExploreViewModel.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/23/26.
//
//
//  MVVM: Explore screen state + orchestration.
//  Refactor (Phase 2): depends on RecommendationFetching (protocol),
//  not directly on APIClient.
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class ExploreViewModel: ObservableObject {

    @Published private(set) var placesByCategoryID: [String: [Place]] = [:]
    @Published private(set) var loadingCategoryID: String? = nil
    @Published var errorMessage: String? = nil

    private let recommendationService: RecommendationFetching
    private let locationProvider: LocationProviding

    init(recommendationService: RecommendationFetching, locationProvider: LocationProviding) {
        self.recommendationService = recommendationService
        self.locationProvider = locationProvider
    }

    func onAppear() {
        locationProvider.requestLocation()
    }

    func ensurePlacesLoaded(for option: CategoryOption, personalAffinity: Double) async {
        if placesByCategoryID[option.id] != nil {
            return
        }

        errorMessage = nil
        loadingCategoryID = option.id
        defer { loadingCategoryID = nil }

        var coord = locationProvider.currentCoordinate()
        if coord == nil {
            locationProvider.requestLocation()
            coord = await locationProvider.waitForCoordinate(timeoutSeconds: 2.0)
        }

        guard let coordinate = coord else {
            errorMessage = "Couldn’t get your location yet. Please try again in a moment."
            return
        }

        do {
            let results = try await recommendationService.fetchRecommendations(
                lat: coordinate.latitude,
                lon: coordinate.longitude,
                categories: option.geoapifyCategories,
                personalAffinity: personalAffinity
            )
            placesByCategoryID[option.id] = results
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearCache(for option: CategoryOption) {
        placesByCategoryID[option.id] = nil
    }

    func clearAllCaches() {
        placesByCategoryID = [:]
    }
}
