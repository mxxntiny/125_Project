//
//  UserProfileStore.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/9/26.
//

//
//  UserProfileStore.swift
//  Your_Places
//
//  Stores user onboarding info (name + selected categories)
//  and persists it locally using UserDefaults.
//

import Foundation
import Combine

final class UserProfileStore: ObservableObject {

    // MARK: - Keys
    private enum Keys {
        static let userName = "userName"
        static let selectedCategoryOptionsJSON = "selectedCategoryOptionsJSON"
    }

    private enum ExtraKeys {
        static let hourlyCountsJSON = "hourlyCategoryCountsJSON"
    }

    // MARK: - Published state
    @Published var userName: String {
        didSet { UserDefaults.standard.set(userName, forKey: Keys.userName) }
    }

    @Published var selectedCategoryOptions: [CategoryOption] {
        didSet { saveSelectedCategories() }
    }

    // IMPORTANT: give a default so init is valid (fixes “self used before…” error)
    @Published var hourlyCategoryCounts: [Int: [String: Int]] = [:] {
        didSet { saveHourlyCounts() }
    }

    // MARK: - Init
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

        // load personalization history
        self.hourlyCategoryCounts = Self.loadHourlyCounts(userDefaults: userDefaults)
    }

    // MARK: - Derived helpers
    var selectedCategoryTitles: [String] {
        selectedCategoryOptions.map { $0.title }
    }

    var isValid: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !selectedCategoryOptions.isEmpty
    }

    // MARK: - Persistence
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

    // MARK: - Reset
    func resetProfile() {
        userName = ""
        selectedCategoryOptions = []
        hourlyCategoryCounts = [:]

        UserDefaults.standard.removeObject(forKey: Keys.userName)
        UserDefaults.standard.removeObject(forKey: Keys.selectedCategoryOptionsJSON)
        UserDefaults.standard.removeObject(forKey: ExtraKeys.hourlyCountsJSON)
    }

    // MARK: - Personalization
    func recordCategoryInteraction(title: String, date: Date = Date()) {
        let hour = Calendar.current.component(.hour, from: date) // 0..23
        var bucket = hourlyCategoryCounts[hour, default: [:]]
        bucket[title, default: 0] += 1
        hourlyCategoryCounts[hour] = bucket
    }

    // MARK: - Category management (for Explore screen)
    func addCategory(_ option: CategoryOption) {
        guard !selectedCategoryOptions.contains(option) else { return }
        selectedCategoryOptions.append(option)
    }

    func removeCategory(_ option: CategoryOption) {
        selectedCategoryOptions.removeAll { $0.id == option.id }
    }
}
