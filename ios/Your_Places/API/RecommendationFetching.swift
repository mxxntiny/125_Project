//
//  RecommendationFetching.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/23/26.
//


//
//  RecommendationService.swift
//  Your_Places
//
//  Service layer wrapper for recommendations.
//  ViewModels depend on the protocol (RecommendationFetching), not APIClient.
//

import Foundation

protocol RecommendationFetching {
    func fetchRecommendations(lat: Double, lon: Double, categories: [String]) async throws -> [Place]
}

struct RecommendationService: RecommendationFetching {
    private let api: APIClient

    init(api: APIClient) {
        self.api = api
    }

    func fetchRecommendations(lat: Double, lon: Double, categories: [String]) async throws -> [Place] {
        try await api.fetchRecommendations(lat: lat, lon: lon, categories: categories)
    }
}