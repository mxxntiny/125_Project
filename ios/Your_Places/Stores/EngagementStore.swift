//
//  EngagementStore.swift
//  Your_Places
//
//  Created by Aidan Huerta on 3/3/26.
//


import Foundation
import Combine

/// Stores and persists behavior/engagement signals used for personalization.
/// Separated from UserProfileStore to keep responsibilities clean.
final class EngagementStore: ObservableObject {

    private enum Keys {
        static let hourlyCountsJSON = "hourlyCategoryCountsJSON"
    }

    /// hour (0..23) -> [categoryTitle: count]
    @Published var hourlyCategoryCounts: [Int: [String: Int]] = [:] {
        didSet { saveHourlyCounts() }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.hourlyCategoryCounts = Self.loadHourlyCounts(userDefaults: userDefaults)
    }

    // MARK: - Persistence

    private static func loadHourlyCounts(userDefaults: UserDefaults) -> [Int: [String: Int]] {
        guard
            let json = userDefaults.string(forKey: Keys.hourlyCountsJSON),
            let data = json.data(using: .utf8),
            let decoded = try? JSONDecoder().decode([Int: [String: Int]].self, from: data)
        else { return [:] }
        return decoded
    }

    private func saveHourlyCounts() {
        let data = (try? JSONEncoder().encode(hourlyCategoryCounts)) ?? Data()
        let json = String(data: data, encoding: .utf8) ?? ""
        UserDefaults.standard.set(json, forKey: Keys.hourlyCountsJSON)
    }

    // MARK: - Reset

    func reset() {
        hourlyCategoryCounts = [:]
        UserDefaults.standard.removeObject(forKey: Keys.hourlyCountsJSON)
    }

    // MARK: - Scoring helpers

    /// Total interactions across all hours for a category title.
    func totalInteractionCount(for title: String) -> Int {
        hourlyCategoryCounts.values.reduce(0) { partial, bucket in
            partial + (bucket[title] ?? 0)
        }
    }

    /// Hour-specific interactions (0..23).
    func interactionCount(for title: String, hour: Int) -> Int {
        hourlyCategoryCounts[hour]?[title] ?? 0
    }

    /// Record meaningful engagement (place tap / save / navigate), not just expanding a dropdown.
    func recordEngagement(categoryTitle: String, date: Date = Date()) {
        let hour = Calendar.current.component(.hour, from: date)
        var bucket = hourlyCategoryCounts[hour, default: [:]]
        bucket[categoryTitle, default: 0] += 1
        hourlyCategoryCounts[hour] = bucket
    }
}