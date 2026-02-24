//
//  Place.swift
//  Your_Places
//
//  Created by Aidan Huerta on 1/29/26.
//


/* This file defines the data model for a single place returned by the backend.
//
// It is responsible for:
// - Describing the structure of a place (name, location, distance, score, etc.)
// - Decoding JSON responses from the backend into Swift objects
// - Providing a unique identifier for SwiftUI list rendering
//
// You should modify this file ONLY when:
// - The backend JSON response structure changes
// - New fields are added or removed by the backend
//
// This file should NOT contain:
// - UI logic
// - Networking logic
// - Location or permission logic
//
// Keep this file focused on representing backend data only.
*/


import Foundation
// Foundation provides basic data types and utilities used by Swift


// Place represents ONE location returned from the backend
// It matches the JSON structure returned by the FastAPI server
struct Place: Decodable, Identifiable {
    
    

    // SwiftUI requires a unique id for each item in a list
    // The backend does not provide an id, so we generate one locally
    var id: String { place_id ?? "\(lat),\(lon),\(name ?? "")" }

    let place_id: String?

    // Name of the place (optional)
    let name: String?
    
    // Address of the place (optional)
    let address: String?
    
    // Categories describing the place (optional)
    let categories: [String]?
    
    // Latitude of the place (required)
    let lat: Double
    
    // Longitude of the place (required)
    let lon: Double
    
    // Distance from the user in meters (optional)
    let distance_m: Double?
    
    // Overall recommendation score calculated by the backend
    let score: Double
    
    let route_length_m: Int?
    let travel_time_s: Int?
    let traffic_delay_s: Int?
    let traffic_length_m: Int?
}
