//
//  RootView.swift
//  Your_Places
//
//  Created by Aidan Huerta on 2/9/26.
//

import SwiftUI

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    let recommendationService: RecommendationFetching

    var body: some View {
        if hasCompletedOnboarding {
            MainTabView(recommendationService: recommendationService)
        } else {
            OnboardingFlowView()
        }
    }
}

#Preview {
    RootView(recommendationService: RecommendationService(api: APIClient()))
        .environmentObject(UserProfileStore())
        .environmentObject(LocationManager())
}
