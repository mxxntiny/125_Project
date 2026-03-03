//
//  CategorySuggestionPolicy.swift
//  Your_Places
//
//  Created by Aidan Huerta on 3/3/26.
//


import Foundation

/// Pure functions that define how Explore decides what to show.
/// Keeps ranking rules out of SwiftUI views.
enum CategorySuggestionPolicy {

    /// Selected categories pinned at top (stable).
    static func selectedPinned(from selected: [CategoryOption]) -> [CategoryOption] {
        selected.sorted { $0.title < $1.title }
    }

    /// Suggested categories are the categories NOT selected by the user.
    /// They are ranked by past engagement (descending), tie-broken by title.
    static func unselectedRanked(
        allCategories: [CategoryOption],
        selected: [CategoryOption],
        engagementCount: (String) -> Int
    ) -> [CategoryOption] {
        let selectedSet = Set(selected)

        let unselected = allCategories.filter { !selectedSet.contains($0) }

        return unselected.sorted { a, b in
            let ca = engagementCount(a.title)
            let cb = engagementCount(b.title)
            if ca != cb { return ca > cb }
            return a.title < b.title
        }
    }
}