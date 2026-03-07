//
//  PlaceRow.swift
//  Your_Places
//
//  Created by Aidan Huerta on 3/3/26.
//

import SwiftUI

struct PlaceRow: View {
    let place: Place
    let categoryTitle: String
    let personalAffinity: Double

    private var explanationText: String? {
        if personalAffinity >= 0.6 {
            return "Because you often explore \(categoryTitle)"
        }

        if let delay = place.traffic_delay_s, delay <= 120 {
            return "Low traffic right now"
        }

        if let distance = place.distance_m, distance <= 500 {
            return "Close to you"
        }

        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(place.name ?? "Unnamed place")
                .font(.subheadline)
                .fontWeight(.semibold)

            Text(place.address ?? "No address available")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let explanationText {
                Text(explanationText)
                    .font(.caption2)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}
