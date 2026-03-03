//
//  PlaceRow.swift
//  Your_Places
//
//  Created by Aidan Huerta on 3/3/26.
//


import SwiftUI

struct PlaceRow: View {
    let place: Place

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(place.name ?? "Unnamed place")
                .font(.subheadline)
                .fontWeight(.semibold)

            Text(place.address ?? "No address available")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}