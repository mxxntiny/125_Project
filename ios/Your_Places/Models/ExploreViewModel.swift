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

    init(recommendationService: RecommendationFetching) {
        self.recommendationService = recommendationService
    }

    func selectCategory(_ option: CategoryOption) {
        selectedCategory = option
    }

    func clearResults() {
        places = []
        errorMessage = nil
    }

    func loadRecommendations(for option: CategoryOption, coordinate: CLLocationCoordinate2D) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

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
