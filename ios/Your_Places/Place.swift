//
//  Place.swift
//  Your_Places
//
//  Created by Aidan Huerta on 1/29/26.
//

import Foundation

struct Place: Decodable, Identifiable {
    // Backend doesn't send an id, so create one locally
    let id = UUID()

    let name: String?
    let address: String?
    let categories: [String]?
    let lat: Double
    let lon: Double
    let distance_m: Double?
    let score: Double
}
