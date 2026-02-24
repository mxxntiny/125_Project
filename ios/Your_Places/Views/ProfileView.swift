//
//  ProfileView.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/9/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var profile: UserProfileStore
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    Text(profile.userName.isEmpty ? "No name set" : profile.userName)
                }

                Section("Selected Categories") {
                    if profile.selectedCategoryOptions.isEmpty {
                        Text("No categories selected.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(profile.selectedCategoryOptions) { option in
                            Text(option.title)
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        profile.resetProfile()
                        hasCompletedOnboarding = false // send user back to onboarding
                    } label: {
                        Text("Reset Profile")
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserProfileStore())
}
