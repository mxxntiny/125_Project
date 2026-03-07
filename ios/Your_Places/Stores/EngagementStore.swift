//
//  EngagementStore.swift
//  Your_Places
//
//  Created by Aidan Huerta on 3/3/26.
//


import Foundation
import Combine

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
    
    func totalInteractionCount(for title: String) -> Int {
        hourlyCategoryCounts.values.reduce(0) { partial, bucket in
            partial + (bucket[title] ?? 0)
        }
    }
    
    func interactionCount(for title: String, hour: Int) -> Int {
        hourlyCategoryCounts[hour]?[title] ?? 0
    }
    
    func affinityNow(for title: String, date: Date = Date()) -> Double {
        let hour = Calendar.current.component(.hour, from: date)
        
        guard let bucket = hourlyCategoryCounts[hour], !bucket.isEmpty else {
            return 0.0
        }
        
        let maxCount = bucket.values.max() ?? 0
        guard maxCount > 0 else { return 0.0 }
        
        let count = bucket[title] ?? 0
        return Double(count) / Double(maxCount)
    }
    
    func recordEngagement(categoryTitle: String, date: Date = Date()) {
        let hour = Calendar.current.component(.hour, from: date)
        var bucket = hourlyCategoryCounts[hour, default: [:]]
        bucket[categoryTitle, default: 0] += 1
        hourlyCategoryCounts[hour] = bucket
    }
    
    // MARK: - Demo personas
    
    func seedStudentScenario() {
        hourlyCategoryCounts = [
            8: [
                "Coffee": 12,
                "Study": 10,
                "Food": 3
            ],
            10: [
                "Study": 11,
                "Coffee": 8,
                "Shopping": 2
            ],
            12: [
                "Food": 9,
                "Coffee": 5,
                "Study": 4
            ],
            15: [
                "Study": 8,
                "Coffee": 4,
                "Shopping": 5
            ]
        ]
    }
    
    func seedActiveSocialScenario() {
        hourlyCategoryCounts = [
            7: [
                "Fitness": 11,
                "Coffee": 1
            ],
            11: [
                "Outdoors": 10,
                "Entertainment": 4,
                "Coffee": 1
            ],
            18: [
                "Entertainment": 7,
                "Nightlife": 6,
                "Fitness": 2
            ],
            21: [
                "Nightlife": 12,
                "Entertainment": 7,
                "Coffee": 1
            ]
        ]
    }
}
