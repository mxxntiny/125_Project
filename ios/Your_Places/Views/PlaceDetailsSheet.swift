//
//  PlaceDetailsSheet.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/23/26.
//


import SwiftUI

struct PlaceDetailsSheet: View {
    let place: Place
    private let api = APIClient()

    @StateObject private var vm: PlaceDetailsViewModel

    init(place: Place) {
        self.place = place
        _vm = StateObject(wrappedValue: PlaceDetailsViewModel(api: APIClient()))
    }

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Loading details...")
                } else if let err = vm.errorMessage {
                    VStack(spacing: 12) {
                        Text("Couldn’t load details")
                            .font(.headline)
                        Text(err)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                } else if let d = vm.details {
                    List {
                        Section("Contact") {
                            if let phone = d.phone, !phone.isEmpty {
                                Text("Phone: \(phone)")
                            } else {
                                Text("Phone: N/A").foregroundStyle(.secondary)
                            }

                            if let website = d.website, !website.isEmpty {
                                Text("Website: \(website)")
                            } else {
                                Text("Website: N/A").foregroundStyle(.secondary)
                            }
                        }

                        Section("Hours") {
                            if let raw = d.opening_hours?.raw, !raw.isEmpty {
                                Text(raw)
                            } else {
                                Text("Hours not available").foregroundStyle(.secondary)
                            }
                        }

                        Section("Location") {
                            Text("Lat: \(place.lat)")
                            Text("Lon: \(place.lon)")
                        }
                    }
                } else {
                    Text("No details available.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(place.name ?? "Details")
            .task {
                guard let pid = place.place_id else {
                    vm.errorMessage = "No place_id available for this result."
                    return
                }
                await vm.load(placeId: pid)
            }
        }
    }
}
