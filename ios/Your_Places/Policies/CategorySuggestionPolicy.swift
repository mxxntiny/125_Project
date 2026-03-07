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

    /// Selected categories stay in the top section, but their order is dynamic.
    /// Ranking priority:
    /// 1. current-hour affinity (descending)
    /// 2. total engagement count (descending)
    /// 3. title (alphabetical tie-break)
    static func selectedRanked(
        from selected: [CategoryOption],
        affinityNow: (String) -> Double,
        engagementCount: (String) -> Int
    ) -> [CategoryOption] {
        selected.sorted { a, b in
            let affinityA = affinityNow(a.title)
            let affinityB = affinityNow(b.title)
            if affinityA != affinityB { return affinityA > affinityB }

            let countA = engagementCount(a.title)
            let countB = engagementCount(b.title)
            if countA != countB { return countA > countB }

            return a.title < b.title
        }
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
