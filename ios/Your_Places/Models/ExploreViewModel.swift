//
//  ExploreViewModel.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/23/26.
//
//
//  Architecture refactor (MVVM):
//  - Holds Explore screen state (places/loading/error/selected category)
//  - Performs API calls via APIClient
//  - Keeps ExploreView focused on UI rendering + user interactions
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

    private let api: APIClient

    init(api: APIClient) {
        self.api = api
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
            let results = try await api.fetchRecommendations(
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
