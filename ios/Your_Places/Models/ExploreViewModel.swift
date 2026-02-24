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
    @Published private(set) var places: [Place] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedCategory: CategoryOption? = nil

    private let recommendationService: RecommendationFetching
    private let locationProvider: LocationProviding

    init(recommendationService: RecommendationFetching, locationProvider: LocationProviding) {
        self.recommendationService = recommendationService
        self.locationProvider = locationProvider
    }

    func onAppear() {
        // VM owns the “start location request” responsibility now.
        locationProvider.requestLocation()
    }

    func didSelectCategory(_ option: CategoryOption) async {
        selectedCategory = option
        errorMessage = nil
        places = []

        isLoading = true
        defer { isLoading = false }

        // Try to get location quickly; if not, request + wait briefly.
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
                categories: option.geoapifyCategories
            )
            places = results
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
