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
    @AppStorage("selectedCategoriesCSV") var selectedCategoriesCSV: String = ""

    var selectedCategories: [String] {
        get {
            selectedCategoriesCSV
                .split(separator: ",")
                .map { String($0) }
                .filter { !$0.isEmpty }
        }
        set {
            selectedCategoriesCSV = newValue.joined(separator: ",")
        }
    }

    var isValid: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !selectedCategories.isEmpty
    }
}
