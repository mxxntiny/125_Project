//
//  Untitled.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/9/26.
//

import SwiftUI
import CoreLocation
import Foundation

struct CategoryOption: Identifiable, Codable, Hashable {
    var id: String { title }          // stable identity
    let title: String
    let geoapifyCategories: [String]
}
enum CategoryCatalog {
    static let all: [CategoryOption] = [
        CategoryOption(title: "Coffee", geoapifyCategories: [
            "catering.cafe.coffee",
            "catering.cafe.coffee_shop"
        ]),
        CategoryOption(title: "Food", geoapifyCategories: [
            "catering.restaurant"
        ]),
        CategoryOption(title: "Dessert", geoapifyCategories: [
            "catering.cafe.dessert",
            "catering.ice_cream"
        ]),
        CategoryOption(title: "Study", geoapifyCategories: [
            "education.library",
            "office.coworking"
        ]),
        CategoryOption(title: "Fitness", geoapifyCategories: [
            "sport.fitness.fitness_centre",
            "sport.sports_centre"
        ]),
        CategoryOption(title: "Outdoors", geoapifyCategories: [
            "natural",
            "leisure.park"
        ]),
        CategoryOption(title: "Shopping", geoapifyCategories: [
            "commercial.shopping_mall",
            "commercial.supermarket"
        ]),
        CategoryOption(title: "Entertainment", geoapifyCategories: [
            "entertainment.cinema",
            "entertainment.museum"
        ]),
        CategoryOption(title: "Nightlife", geoapifyCategories: [
            "catering.bar",
            "adult.nightclub"
        ]),
        CategoryOption(title: "Parks", geoapifyCategories: [
            "leisure.park"
        ])
    ]
}
