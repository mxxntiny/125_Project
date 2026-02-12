//
//  UserProfileStore.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/9/26.
//

import SwiftUI
import Combine

final class UserProfileStore: ObservableObject {
    @AppStorage("userName") var userName: String = ""

    // Store selected CategoryOption objects as JSON text in AppStorage
    @AppStorage("selectedCategoryOptionsJSON") private var selectedCategoryOptionsJSON: String = ""

    var selectedCategoryOptions: [CategoryOption] {
        get {
            guard let data = selectedCategoryOptionsJSON.data(using: .utf8) else { return [] }
            return (try? JSONDecoder().decode([CategoryOption].self, from: data)) ?? []
        }
        set {
            let data = (try? JSONEncoder().encode(newValue)) ?? Data()
            selectedCategoryOptionsJSON = String(data: data, encoding: .utf8) ?? ""
        }
    }

    // Convenience: just the display titles
    var selectedCategoryTitles: [String] {
        selectedCategoryOptions.map { $0.title }
    }

    var isValid: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !selectedCategoryOptions.isEmpty
    }
}
