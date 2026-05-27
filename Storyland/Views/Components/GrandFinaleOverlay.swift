//
//  GrandFinaleOverlay.swift
//  Storyland
//

import SwiftUI

struct GrandFinaleOverlay: View {
    let totalStories: Int
    let onDismiss: () -> Void

    @State private var crownScale: CGFloat = 0.1
    @State private var crownRotation: Double = -180
    @State private var contentOpacity: Double = 0
    @State private var pulse: Bool = false
    @State private var rainbowShift: Double = 0
    @State private var sparkleRotation: Double = 0
    @State private var haloRotation: Double = 0
    @State private var burstCounter: Int = 0
    @State private var starsBounce: Bool = false

    var body: some View {
        ZStack {
            animatedBackground

            ForEach(0..<3, id: \.self) { layer in
                ConfettiView()
                    .ignoresSafeArea()
                    .id("burst_\(burstCounter)_\(layer)")
            }

            orbitingSparkles

            VStack(spacing: 24) {
                crownBadge

                textBlock
                    .opacity(contentOpacity)

                starsRow
                    .opacity(contentOpacity)

                continueButton
                    .opacity(contentOpacity)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 32)
        }
        .onAppear(perform: startAnimations)
    }

    private var animatedBackground: some View {
        ZStack {
            AngularGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.96, green: 0.31, blue: 0.51),
                    Color(red: 0.99, green: 0.61, blue: 0.27),
                    Color(red: 1.00, green: 0.84, blue: 0.31),
                    Color(red: 0.31, green: 0.81, blue: 0.55),
                    Color(red: 0.40, green: 0.69, blue: 0.97),
                    Color(red: 0.55, green: 0.36, blue: 0.95),
                    Color(red: 0.96, green: 0.31, blue: 0.51)
                ]),
                center: .center,
                angle: .degrees(rainbowShift)
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(0.45)],
                center: .center,
                startRadius: 80,
                endRadius: 500
            )
            .ignoresSafeArea()
        }
    }

    private var orbitingSparkles: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { index in
                Image(systemName: index.isMultiple(of: 2) ? "sparkle" : "star.fill")
                    .font(.system(size: index.isMultiple(of: 2) ? 28 : 20, weight: .black))
                    .foregroundStyle(.white)
                    .shadow(color: .yellow.opacity(0.7), radius: 8)
                    .offset(y: -220)
                    .rotationEffect(.degrees(Double(index) * 36 + haloRotation))
                    .opacity(0.9)
            }
        }
        .allowsHitTesting(false)
    }

    private var crownBadge: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.85),
                            Color.yellow.opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)
                .scaleEffect(pulse ? 1.15 : 0.95)
                .blur(radius: 10)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.00, green: 0.84, blue: 0.31),
                            Color(red: 0.99, green: 0.61, blue: 0.27)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 170, height: 170)
                .overlay(
                    Circle().stroke(Color.white.opacity(0.85), lineWidth: 4)
                )
                .scaleEffect(pulse ? 1.06 : 1.0)
                .shadow(color: Color.orange.opacity(0.55), radius: 30, y: 12)

            Image(systemName: "crown.fill")
                .font(.system(size: 96, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color.yellow.opacity(0.95)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.35), radius: 8, y: 4)
                .scaleEffect(crownScale)
                .rotationEffect(.degrees(crownRotation))
        }
    }

    private var textBlock: some View {
        VStack(spacing: 10) {
            Text("Reading Master!")
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color.yellow.opacity(0.95)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.45), radius: 10, y: 4)
                .multilineTextAlignment(.center)

            Text("You completed all \(totalStories) tales!")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.5), radius: 6, y: 2)
                .multilineTextAlignment(.center)

            Text("You are a true reading hero.")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.95))
                .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
                .multilineTextAlignment(.center)
                .padding(.top, 2)
        }
    }

    private var starsRow: some View {
        HStack(spacing: 10) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: "star.fill")
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.35), radius: 6, y: 3)
                    .scaleEffect(starsBounce ? 1.15 : 0.9)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.12),
                        value: starsBounce
                    )
            }
        }
        .padding(.top, 4)
    }

    private var continueButton: some View {
        Button {
            HapticManager.tap()
            onDismiss()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                Text("Amazing!")
            }
            .font(.appButton)
            .foregroundStyle(Color(red: 0.96, green: 0.31, blue: 0.51))
            .padding(.vertical, 16)
            .padding(.horizontal, 40)
            .background(.white, in: Capsule())
            .overlay(
                Capsule().stroke(Color.white.opacity(0.9), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.3), radius: 14, y: 8)
        }
        .buttonStyle(BouncyButtonStyle())
    }

    private func startAnimations() {
        HapticManager.celebrate()

        withAnimation(.spring(response: 0.75, dampingFraction: 0.5)) {
            crownScale = 1.0
            crownRotation = 0
        }
        withAnimation(.easeOut(duration: 0.55).delay(0.35)) {
            contentOpacity = 1.0
        }
        withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true).delay(0.5)) {
            pulse = true
        }
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            rainbowShift = 360
        }
        withAnimation(.linear(duration: 14.0).repeatForever(autoreverses: false)) {
            haloRotation = 360
        }
        starsBounce = true

        Task {
            for _ in 0..<6 {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                await MainActor.run {
                    burstCounter += 1
                    HapticManager.tap()
                }
            }
        }
    }
}

#Preview {
    GrandFinaleOverlay(totalStories: 320) {}
}
