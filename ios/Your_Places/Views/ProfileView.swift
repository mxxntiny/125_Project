//
//  ProfileView.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/9/26.
//

import SwiftUI

extension Notification.Name {
    static let demoPersonaDidChange = Notification.Name("demoPersonaDidChange")
}

struct ProfileView: View {
    @EnvironmentObject private var profile: UserProfileStore
    @EnvironmentObject private var engagement: EngagementStore

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    private var studentCategories: [CategoryOption] {
        CategoryCatalog.all.filter {
            ["Study", "Coffee", "Food", "Shopping"].contains($0.title)
        }
    }

    private var activeSocialCategories: [CategoryOption] {
        CategoryCatalog.all.filter {
            ["Fitness", "Outdoors", "Nightlife", "Entertainment", "Coffee"].contains($0.title)
        }
    }

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

                Section("Demo Personas") {
                    Button("Load Student Persona") {
                        profile.userName = "Student Demo"
                        profile.setSelectedCategories(studentCategories)
                        engagement.seedStudentScenario()
                        NotificationCenter.default.post(name: .demoPersonaDidChange, object: nil)
                    }

                    Button("Load Active yet Social Persona") {
                        profile.userName = "Active Social Demo"
                        profile.setSelectedCategories(activeSocialCategories)
                        engagement.seedActiveSocialScenario()
                        NotificationCenter.default.post(name: .demoPersonaDidChange, object: nil)
                    }
                }

                Section("Current Engagement Snapshot") {
                    if engagement.hourlyCategoryCounts.isEmpty {
                        Text("No engagement data stored.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(engagement.hourlyCategoryCounts.keys.sorted(), id: \.self) { hour in
                            let bucket = engagement.hourlyCategoryCounts[hour] ?? [:]
                            let summary = bucket
                                .sorted { lhs, rhs in
                                    if lhs.value == rhs.value {
                                        return lhs.key < rhs.key
                                    }
                                    return lhs.value > rhs.value
                                }
                                .map { "\($0.key): \($0.value)" }
                                .joined(separator: ", ")

                            Text("\(hour):00 — \(summary)")
                                .font(.footnote)
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        profile.resetProfile()
                        engagement.reset()
                        hasCompletedOnboarding = false
                        NotificationCenter.default.post(name: .demoPersonaDidChange, object: nil)
                    } label: {
                        Text("Reset Demo State")
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
        .environmentObject(EngagementStore())
}
