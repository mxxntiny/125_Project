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
    
    /// Persona 1: The Student
    /// Interests: Study, Coffee, Food, Shopping
    func seedStudentScenario() {
        hourlyCategoryCounts = [
            0:  ["Study": 2, "Coffee": 1, "Food": 1],
            1:  ["Study": 2, "Coffee": 1],
            2:  ["Study": 1],
            3:  ["Study": 1],
            4:  ["Study": 1],
            5:  ["Coffee": 2, "Study": 1],
            6:  ["Coffee": 4, "Study": 2, "Food": 1],
            7:  ["Coffee": 7, "Study": 5, "Food": 2],
            8:  ["Coffee": 12, "Study": 10, "Food": 3],
            9:  ["Coffee": 10, "Study": 11, "Food": 3],
            10: ["Study": 12, "Coffee": 8, "Shopping": 2],
            11: ["Study": 11, "Coffee": 7, "Food": 4],
            12: ["Food": 10, "Coffee": 6, "Study": 5],
            13: ["Food": 8, "Study": 7, "Coffee": 4],
            14: ["Study": 9, "Coffee": 5, "Shopping": 3],
            15: ["Study": 8, "Coffee": 4, "Shopping": 5],
            16: ["Study": 7, "Coffee": 4, "Food": 3],
            17: ["Food": 6, "Study": 5, "Shopping": 4],
            18: ["Food": 7, "Coffee": 3, "Shopping": 4],
            19: ["Food": 6, "Shopping": 5, "Coffee": 2],
            20: ["Study": 4, "Coffee": 2, "Shopping": 3],
            21: ["Study": 5, "Coffee": 2],
            22: ["Study": 4, "Coffee": 1],
            23: ["Study": 3, "Coffee": 1]
        ]
    }
    
    /// Persona 2: The Active yet Social Person
    /// Interests: Fitness, Outdoors, Nightlife, Entertainment, Coffee
    func seedActiveSocialScenario() {
        hourlyCategoryCounts = [
            0:  ["Nightlife": 8, "Entertainment": 6, "Coffee": 1],
            1:  ["Nightlife": 7, "Entertainment": 5],
            2:  ["Nightlife": 4, "Entertainment": 3],
            3:  ["Entertainment": 2],
            4:  ["Fitness": 1],
            5:  ["Fitness": 3, "Coffee": 1],
            6:  ["Fitness": 7, "Coffee": 2],
            7:  ["Fitness": 11, "Coffee": 2, "Outdoors": 3],
            8:  ["Fitness": 9, "Outdoors": 4, "Coffee": 2],
            9:  ["Outdoors": 7, "Fitness": 6, "Coffee": 2],
            10: ["Outdoors": 9, "Fitness": 5, "Entertainment": 2],
            11: ["Outdoors": 10, "Entertainment": 4, "Coffee": 2],
            12: ["Outdoors": 8, "Entertainment": 4, "Coffee": 2],
            13: ["Outdoors": 7, "Entertainment": 5, "Fitness": 3],
            14: ["Entertainment": 6, "Outdoors": 6, "Coffee": 1],
            15: ["Entertainment": 7, "Outdoors": 5, "Fitness": 2],
            16: ["Entertainment": 8, "Outdoors": 4, "Coffee": 1],
            17: ["Entertainment": 7, "Nightlife": 5, "Fitness": 2],
            18: ["Entertainment": 8, "Nightlife": 7, "Coffee": 1],
            19: ["Nightlife": 9, "Entertainment": 7, "Coffee": 1],
            20: ["Nightlife": 11, "Entertainment": 8, "Coffee": 1],
            21: ["Nightlife": 12, "Entertainment": 7, "Coffee": 1],
            22: ["Nightlife": 10, "Entertainment": 6],
            23: ["Nightlife": 9, "Entertainment": 5]
        ]
    }
}
