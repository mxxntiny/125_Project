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

    private var rankedSelectedCategories: [CategoryOption] {
        CategorySuggestionPolicy.selectedRanked(
            from: profile.selectedCategoryOptions,
            affinityNow: { title in
                engagement.affinityNow(for: title)
            },
            engagementCount: { title in
                engagement.totalInteractionCount(for: title)
            }
        )
    }

    private var currentHour: Int {
        Calendar.current.component(.hour, from: Date())
    }

    private var sortedHoursForDisplay: [Int] {
        let hours = engagement.hourlyCategoryCounts.keys.sorted()
        return hours.sorted { a, b in
            if a == currentHour { return true }
            if b == currentHour { return false }
            return a < b
        }
    }

    private func rankingReason(for option: CategoryOption) -> String {
        let affinity = engagement.affinityNow(for: option.title)
        let total = engagement.totalInteractionCount(for: option.title)

        if affinity >= 0.75 {
            return "Frequently used this time of day"
        } else if affinity >= 0.45 {
            return "Strong recent engagement"
        } else if total >= 5 {
            return "Boosted by past interactions"
        } else {
            return "Lower current priority"
        }
    }

    private func affinityPercent(for option: CategoryOption) -> Int {
        Int((engagement.affinityNow(for: option.title) * 100).rounded())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    Text(profile.userName.isEmpty ? "No name set" : profile.userName)
                }

                Section("Selected Categories") {
                    if rankedSelectedCategories.isEmpty {
                        Text("No categories selected.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(rankedSelectedCategories.enumerated()), id: \.element.id) { index, option in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("\(index + 1). \(option.title)")
                                        .font(.body)

                                    Spacer()

                                    Text("Affinity \(affinityPercent(for: option))%")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Text(rankingReason(for: option))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 2)
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
                        ForEach(sortedHoursForDisplay, id: \.self) { hour in
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

                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text("\(hour):00 — \(summary)")
                                        .font(.footnote)

                                    if hour == currentHour {
                                        Text("Current hour")
                                            .font(.caption2)
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
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
