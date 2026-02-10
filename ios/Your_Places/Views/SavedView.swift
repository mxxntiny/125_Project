//
//  SavedView.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/9/26.
//

import SwiftUI

struct SavedView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Saved places") {
                    Text("No saved places yet.")
                        .foregroundStyle(.secondary)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Saved")
        }
    }
}
