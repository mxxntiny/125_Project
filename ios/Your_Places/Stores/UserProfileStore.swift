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

    @Published var userName: String {
        didSet { UserDefaults.standard.set(userName, forKey: Keys.userName) }
    }

    @Published var selectedCategoryOptions: [CategoryOption] {
        didSet { saveSelectedCategories() }
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

    func resetProfile() {
        userName = ""
        selectedCategoryOptions = []

        UserDefaults.standard.removeObject(forKey: Keys.userName)
        UserDefaults.standard.removeObject(forKey: Keys.selectedCategoryOptionsJSON)
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
