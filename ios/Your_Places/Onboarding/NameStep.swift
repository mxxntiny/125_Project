//
//  NameStep.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/9/26.
//

import SwiftUI

struct NameStep: View {
    @Binding var name: String
    let onBack: () -> Void
    let onContinue: () -> Void

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Text("What should we call you?")
                .font(.title2).bold()

            TextField("Enter your name", text: $name)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)

            Spacer()

            HStack(spacing: 12) {
                Button("Back") { onBack() }
                    .buttonStyle(.bordered)

                Button("Continue") { onContinue() }
                    .buttonStyle(.borderedProminent)
                    .disabled(trimmedName.isEmpty)
            }
            .padding(.bottom, 12)
        }
        .padding(.horizontal)
    }
}
