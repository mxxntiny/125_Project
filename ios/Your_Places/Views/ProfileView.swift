//
//  ProfileView.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/9/26.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("selectedCategoriesCSV") private var selectedCategoriesCSV: String = ""
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    private var categories: [String] {
        selectedCategoriesCSV.split(separator: ",").map(String.init)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Profile") {
                    Text("Name: \(userName.isEmpty ? "Not set" : userName)")
                    Text("Preferences: \(categories.isEmpty ? "None" : categories.joined(separator: ", "))")
                        .foregroundStyle(.secondary)
                }

                Section("Debug / Demo Controls") {
                    Button(role: .destructive) {
                        hasCompletedOnboarding = false
                    } label: {
                        Text("Reset Onboarding")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
        }
    }
}
