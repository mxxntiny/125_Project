//
//  UserProfileStore.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/9/26.
//
//  Stores user onboarding info (name + selected categories)
//  and persists it locally using UserDefaults.
//

import Foundation
import Combine

final class UserProfileStore: ObservableObject {

    private enum Keys {
        static let userName = "userName"
        static let selectedCategoryOptionsJSON = "selectedCategoryOptionsJSON"
    }

    private enum ExtraKeys {
        static let hourlyCountsJSON = "hourlyCategoryCountsJSON"
    }

    @Published var userName: String {
        didSet { UserDefaults.standard.set(userName, forKey: Keys.userName) }
    }

    @Published var selectedCategoryOptions: [CategoryOption] {
        didSet { saveSelectedCategories() }
    }

    @Published var hourlyCategoryCounts: [Int: [String: Int]] = [:] {
        didSet { saveHourlyCounts() }
    }

    init(userDefaults: UserDefaults = .standard) {
        let storedName = userDefaults.string(forKey: Keys.userName) ?? ""
        self.userName = storedName

        if let json = userDefaults.string(forKey: Keys.selectedCategoryOptionsJSON),
           let data = json.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([CategoryOption].self, from: data) {
            self.selectedCategoryOptions = decoded
        } else {
            self.selectedCategoryOptions = []
        }

        self.hourlyCategoryCounts = Self.loadHourlyCounts(userDefaults: userDefaults)
    }

    var selectedCategoryTitles: [String] {
        selectedCategoryOptions.map { $0.title }
    }

    var isValid: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !selectedCategoryOptions.isEmpty
    }

    private func saveSelectedCategories() {
        let data = (try? JSONEncoder().encode(selectedCategoryOptions)) ?? Data()
        let json = String(data: data, encoding: .utf8) ?? ""
        UserDefaults.standard.set(json, forKey: Keys.selectedCategoryOptionsJSON)
    }

    private static func loadHourlyCounts(userDefaults: UserDefaults) -> [Int: [String: Int]] {
        guard
            let json = userDefaults.string(forKey: ExtraKeys.hourlyCountsJSON),
            let data = json.data(using: .utf8),
            let decoded = try? JSONDecoder().decode([Int: [String: Int]].self, from: data)
        else { return [:] }
        return decoded
    }

    private func saveHourlyCounts() {
        let data = (try? JSONEncoder().encode(hourlyCategoryCounts)) ?? Data()
        let json = String(data: data, encoding: .utf8) ?? ""
        UserDefaults.standard.set(json, forKey: ExtraKeys.hourlyCountsJSON)
    }

    func resetProfile() {
        userName = ""
        selectedCategoryOptions = []
        hourlyCategoryCounts = [:]

        UserDefaults.standard.removeObject(forKey: Keys.userName)
        UserDefaults.standard.removeObject(forKey: Keys.selectedCategoryOptionsJSON)
        UserDefaults.standard.removeObject(forKey: ExtraKeys.hourlyCountsJSON)
    }

    // MARK: - Ranking (unselected categories)
    /// Total interactions across all hours for a category title.
    func totalInteractionCount(for title: String) -> Int {
        hourlyCategoryCounts.values.reduce(0) { partial, bucket in
            partial + (bucket[title] ?? 0)
        }
    }

    // MARK: - Engagement tracking (use this on place taps, not on expand)
    func recordRecommendationEngagement(categoryTitle: String, date: Date = Date()) {
        let hour = Calendar.current.component(.hour, from: date)
        var bucket = hourlyCategoryCounts[hour, default: [:]]
        bucket[categoryTitle, default: 0] += 1
        hourlyCategoryCounts[hour] = bucket
    }

    // MARK: - Category management
    func addCategory(_ option: CategoryOption) {
        guard !selectedCategoryOptions.contains(option) else { return }
        selectedCategoryOptions.append(option)
    }

    func removeCategory(_ option: CategoryOption) {
        selectedCategoryOptions.removeAll { $0.id == option.id }
    }
}
