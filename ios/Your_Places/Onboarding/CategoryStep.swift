//
//  CategoryStep.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/9/26.
//

import SwiftUI

struct CategoryStep: View {
    @Binding var selected: Set<String>
    let onBack: () -> Void
    let onFinish: () -> Void

    private let categories = [
        "Coffee", "Food", "Dessert", "Study", "Fitness",
        "Outdoors", "Shopping", "Entertainment", "Nightlife", "Parks"
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
                    ForEach(categories, id: \.self) { cat in
                        Button {
                            toggle(cat)
                        } label: {
                            HStack {
                                Text(cat)
                                Spacer()
                                Image(systemName: selected.contains(cat) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selected.contains(cat) ? .primary : .tertiary)
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

    private func toggle(_ cat: String) {
        if selected.contains(cat) { selected.remove(cat) }
        else { selected.insert(cat) }
    }
}
