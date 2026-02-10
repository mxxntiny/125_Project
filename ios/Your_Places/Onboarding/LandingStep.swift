//
//  LandingStep.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/9/26.
//

import SwiftUI

struct LandingStep: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Spacer()

            Text("Your Places")
                .font(.largeTitle).bold()

            Text("Personalized place recommendations near you.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button {
                onContinue()
            } label: {
                Text("Get Started")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            Spacer().frame(height: 12)
        }
    }
}
