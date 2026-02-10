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
        ZStack {
            // 1) Welcoming background gradient
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.24, green: 0.60, blue: 0.92), location: 0.00), // deep sky blue
                    .init(color: Color(red: 0.55, green: 0.80, blue: 0.98), location: 0.30), // light sky
                    .init(color: Color(red: 0.98, green: 0.90, blue: 0.62), location: 0.55), // warm sunlight
                    .init(color: Color(red: 0.72, green: 0.86, blue: 0.55), location: 0.78), // soft green
                    .init(color: Color(red: 0.36, green: 0.65, blue: 0.35), location: 1.00)  // deeper green
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // 2) Subtle background shapes (blobs)
            // ☀️ Sun glow (top-left like your image)
            Circle()
                .fill(Color.yellow.opacity(0.28))
                .frame(width: 420, height: 420)
                .blur(radius: 70)
                .offset(x: -170, y: -260)

            // ☁️ Soft cloud haze
            Circle()
                .fill(Color.white.opacity(0.20))
                .frame(width: 360, height: 360)
                .blur(radius: 80)
                .offset(x: 180, y: -220)

            // 🌿 Subtle green depth near bottom
            Circle()
                .fill(Color.green.opacity(0.18))
                .frame(width: 520, height: 520)
                .blur(radius: 90)
                .offset(x: 0, y: 360)
            
            // 3) Foreground content
            VStack(spacing: 18) {
                Spacer()

                // App icon-style badge
                ZStack {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 96, height: 96)
                        .shadow(radius: 14, y: 6)

                    Image("Your_Places_logo_design")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    
                }

                Text("Your Places")
                    .font(.system(size: 38, weight: .bold, design: .rounded))

                Text("Personalized place recommendations near you.")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                Spacer()

                Button {
                    onContinue()
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .padding(.horizontal, 22)
                .padding(.bottom, 18)
            }
        }
    }
}
