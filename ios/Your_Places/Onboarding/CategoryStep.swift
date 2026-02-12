//
//  CategoryStep.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/9/26.
//

import SwiftUI

struct CategoryStep: View {
    @Binding var selected: Set<CategoryOption>
    let onBack: () -> Void
    let onFinish: () -> Void

    private let categories: [CategoryOption] = [
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

    var body: some View {
        VStack(spacing: 12) {
            Text("Pick a few categories you like")
                .font(.title3).bold()
                .padding(.top, 10)

            Text("We’ll use these to personalize recommendations.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            List {
                Section("Categories") {
                    ForEach(categories) { option in
                        Button {
                            toggle(option)
                        } label: {
                            HStack {
                                Text(option.title)
                                Spacer()
                                Image(systemName: selected.contains(option) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selected.contains(option) ? .primary : .tertiary)
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }

                Section {
                    Text("Selected: \(selected.count)")
                        .foregroundStyle(.secondary)
                }
            }
            .listStyle(.insetGrouped)

            HStack(spacing: 12) {
                Button("Back") { onBack() }
                    .buttonStyle(.bordered)

                Button("Finish") { onFinish() }
                    .buttonStyle(.borderedProminent)
                    .disabled(selected.isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
    }

    private func toggle(_ option: CategoryOption) {
        if selected.contains(option) {
            selected.remove(option)
        } else {
            selected.insert(option)
        }
    }
}
