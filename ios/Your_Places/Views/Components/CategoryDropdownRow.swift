//
//  CategoryDropdownRow.swift
//  Your_Places
//
//  Created by Aidan Huerta on 3/3/26.
//


import SwiftUI

struct CategoryDropdownRow<Content: View>: View {
    let title: String
    @Binding var isExpanded: Bool

    /// Optional trailing action (ex: Add button for unselected categories)
    let trailingActionTitle: String?
    let onTrailingAction: (() -> Void)?

    /// Called when user expands the row (good place to trigger fetch)
    let onExpanded: (() -> Void)?

    @ViewBuilder let content: () -> Content

    init(
        title: String,
        isExpanded: Binding<Bool>,
        trailingActionTitle: String? = nil,
        onTrailingAction: (() -> Void)? = nil,
        onExpanded: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self._isExpanded = isExpanded
        self.trailingActionTitle = trailingActionTitle
        self.onTrailingAction = onTrailingAction
        self.onExpanded = onExpanded
        self.content = content
    }

    var body: some View {
        DisclosureGroup(isExpanded: Binding(
            get: { isExpanded },
            set: { newValue in
                isExpanded = newValue
                if newValue { onExpanded?() }
            }
        )) {
            content()
        } label: {
            HStack {
                Text(title)
                Spacer()

                if let trailingActionTitle, let onTrailingAction {
                    Button(trailingActionTitle) {
                        onTrailingAction()
                    }
                    .font(.footnote)
                    .controlSize(.small)
                    .buttonStyle(.borderless) // IMPORTANT: prevent toggling disclosure when tapped
                }
            }
        }
    }
}