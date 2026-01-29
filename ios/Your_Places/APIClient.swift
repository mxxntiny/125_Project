import Foundation

final class APIClient {
    // Simulator -> your Mac
    private let baseURL = URL(string: "http://127.0.0.1:8000")!

    func fetchRecommendations(lat: Double, lon: Double) async throws -> [Place] {
        let url = baseURL.appendingPathComponent("recommendations")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "lat": lat,
            "lon": lon,
            "radius_m": 1500,
            "limit": 25,
            "categories": ["catering.cafe", "catering.restaurant"],
            "prefer_close": 0.7,
            "prefer_high_rating": 0.3
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let text = String(data: data, encoding: .utf8) ?? "<no body>"
            throw NSError(domain: "APIClient", code: http.statusCode, userInfo: [
                NSLocalizedDescriptionKey: "Backend error \(http.statusCode): \(text)"
            ])
        }

        return try JSONDecoder().decode([Place].self, from: data)
    }
}
