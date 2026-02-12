//
//  OnboardingFlowView.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/9/26.
//

import SwiftUI
import Combine

struct OnboardingFlowView: View {
    @StateObject private var profile = UserProfileStore()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    // 0 = landing, 1 = name, 2 = categories
    @State private var step: Int = 0

    var body: some View {
        NavigationStack {
            
            VStack {
                switch step {
                case 0:
                    LandingStep(onContinue: { step = 1 })
                case 1:
                    NameStep(
                        name: $profile.userName,
                        onBack: { step = 0 },
                        onContinue: { step = 2 }
                    )
                default:
                    CategoryStep(
                        selected: Binding(
                            get: { Set(profile.selectedCategoryOptions) },
                            set: { profile.selectedCategoryOptions = Array($0) }
                        ),
                        onBack: { step = 1 },
                        onFinish: {
                            if profile.isValid {
                                hasCompletedOnboarding = true
                            }
                        }
                    )
                }
            }
            .animation(.easeInOut, value: step)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
