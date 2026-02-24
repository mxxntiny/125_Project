//
//  APIClient.swift
//  Your_Places
//
//  Created by Aidan Huerta on 1/29/26.
//


/* This file is responsible ONLY for:
 // - Communicating with the backend server
 // - Sending HTTP requests (JSON) to the backend
 // - Receiving and decoding responses into Swift models
 //
 // Keep this file focused on networking and data transfer only.
*/

import Foundation
// Foundation gives us tools for URLs, HTTP requests, and JSON handling

final class APIClient {

    // If testing on a physical device, "127.0.0.1" will NOT point to your Mac.
    // You'll need to use your Mac's LAN IP instead.
    private let baseURL = URL(string: "http://127.0.0.1:8000")!

    // MARK: - Recommendations

    func fetchRecommendations(
        lat: Double,
        lon: Double,
        categories: [String],
        includeTraffic: Bool = true
    ) async throws -> [Place] {

        let url = baseURL.appendingPathComponent("recommendations")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Updated request body to match new backend fields
        let body: [String: Any] = [
            "lat": lat,
            "lon": lon,
            "radius_m": 1500,
            "limit": 25,
            "categories": categories,

            // Weights (tune as you like; these are reasonable defaults)
            "prefer_close": 0.55,
            "prefer_high_rating": 0.15,
            "prefer_low_traffic": includeTraffic ? 0.30 : 0.0,

            // Feature toggles
            "include_traffic": includeTraffic,
            "include_details": false
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let text = String(data: data, encoding: .utf8) ?? "<no body>"
            throw NSError(
                domain: "APIClient",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Backend error \(http.statusCode): \(text)"]
            )
        }

        return try JSONDecoder().decode([Place].self, from: data)
    }

    // MARK: - Place Details

    struct PlaceDetails: Codable {
        let place_id: String
        let opening_hours: OpeningHours?
        let phone: String?
        let website: String?

        // We keep this flexible because Geoapify opening_hours can be nested/variable.
        // If you want a stricter model later, we can define it.
        struct OpeningHours: Codable {
            let raw: String?

            // This is a small trick: sometimes opening_hours can be an object, sometimes a string.
            // For now we’ll decode it as a generic wrapper.
            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let s = try? container.decode(String.self) {
                    raw = s
                } else {
                    raw = nil
                }
            }
        }
    }

    func fetchPlaceDetails(placeId: String) async throws -> PlaceDetails {
        let url = baseURL
            .appendingPathComponent("place-details")
            .appendingPathComponent(placeId)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let text = String(data: data, encoding: .utf8) ?? "<no body>"
            throw NSError(
                domain: "APIClient",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Backend error \(http.statusCode): \(text)"]
            )
        }

        return try JSONDecoder().decode(PlaceDetails.self, from: data)
    }
}
