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
// You should modify this file ONLY when:
// - Backend endpoints change
// - Request or response JSON formats change
// - Network error handling needs improvement
// - Authentication or headers are added
//
// This file should NOT contain:
// - UI logic
// - Location permission logic
// - User preference or profile decision logic
//
// Keep this file focused on networking and data transfer only.
*/

import Foundation
// Foundation gives us tools for URLs, HTTP requests, and JSON handling

final class APIClient {
    
    // This is the base address of the backend server.
    // While using the iOS Simulator, 127.0.0.1 points to your Mac.
    private let baseURL = URL(string: "http://127.0.0.1:8000")!
    

    
    /* fetchRecommendations sends the user's location to the backend
    // and returns a list of nearby places.
    //
    // async  -> this runs asynchronously (non-blocking)
    // throws -> this function can fail and throw an error
    // [Place] -> returns an array of Place objects
     */
    
    func fetchRecommendations(
        lat: Double,
        lon: Double,
        categories: [String],
    ) async throws -> [Place] {
        

        
        // Build the full endpoint URL:
        // http://127.0.0.1:8000/recommendations
        let url = baseURL.appendingPathComponent("recommendations")
        
        // Create an HTTP request object
        var request = URLRequest(url: url)
        
        // Set the HTTP method to POST
        // HTTP POST method sends data to a server to create or update a resource, with the data included in the body of the request message.
        request.httpMethod = "POST"
        
        // Tells the backend that we are sending JSON data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create the JSON body that will be sent to the backend
        // This is equivalent to a Python dictionary
        // TODO: Update based on Users preferences
        let body: [String: Any] = [
            "lat": lat,
            "lon": lon,
            "radius_m": 1500,
            "limit": 25,
            "categories": categories,
            "prefer_close": 0.7,
            "prefer_high_rating": 0.3
        ]

        // Convert the dictionary into JSON data
        // 'try' is required because JSON conversion can fail
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        // Send the HTTP request to the backend and wait for a response
        // 'data' contains the response body (JSON)
        // 'response' contains metadata like the HTTP status code
        let (data, response) = try await URLSession.shared.data(for: request)

        // Check if the response is an HTTP response
        // and if the status code is NOT in the 200–299 range
        if let http = response as? HTTPURLResponse,
            !(200...299).contains(http.statusCode) {
            
            // Convert error body to readable text (if possible)
            let text = String(data: data, encoding: .utf8) ?? "<no body>"
            
            // Throw an error with the status code and message
            throw NSError(
                domain: "APIClient",
                code: http.statusCode,
                userInfo: [
                    NSLocalizedDescriptionKey: 
                        "Backend error \(http.statusCode): \(text)"
                ]
            )
        }

        // Convert the JSON response into an array of Place objects
        // This requires the JSON to match the Place model exactly
        return try JSONDecoder().decode([Place].self, from: data)
    }
}
