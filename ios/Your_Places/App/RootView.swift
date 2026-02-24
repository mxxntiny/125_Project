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
    let locationProvider: LocationProviding

    var body: some View {
        if hasCompletedOnboarding {
            MainTabView(
                recommendationService: recommendationService,
                locationProvider: locationProvider
            )
        } else {
            OnboardingFlowView()
        }
    }
}

#Preview {
    RootView(
        recommendationService: RecommendationService(api: APIClient()),
        locationProvider: LocationService(manager: LocationManager())
    )
    .environmentObject(UserProfileStore())
    .environmentObject(LocationManager())
}
