//
//  PlaceDetailsViewModel.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/23/26.
//


import Foundation
import Combine

@MainActor
final class PlaceDetailsViewModel: ObservableObject {
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var details: APIClient.PlaceDetails? = nil
    @Published var errorMessage: String? = nil

    private let api: APIClient

    init(api: APIClient) {
        self.api = api
    }

    func load(placeId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            details = try await api.fetchPlaceDetails(placeId: placeId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
