//
//  CelebrationOverlay.swift
//  Storyland
//

import SwiftUI

struct CelebrationOverlay: View {
    let onDismiss: () -> Void

    @State private var starScale: CGFloat = 0.3
    @State private var starRotation: Double = -30
    @State private var contentOpacity: Double = 0
    @State private var pulse: Bool = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .transition(.opacity)

            ConfettiView()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(AppTheme.successGradient)
                        .frame(width: 140, height: 140)
                        .scaleEffect(pulse ? 1.06 : 1.0)
                        .shadow(color: Color.green.opacity(0.45), radius: 24, y: 10)

                    Image(systemName: "star.fill")
                        .font(.system(size: 76, weight: .black))
                        .foregroundStyle(.white)
                        .scaleEffect(starScale)
                        .rotationEffect(.degrees(starRotation))
                        .shadow(color: .black.opacity(0.25), radius: 6, y: 4)
                }

                VStack(spacing: 8) {
                    Text("All correct!")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Great job!")
                        .font(.appSubtitle)
                        .foregroundStyle(.white.opacity(0.92))
                }
                .opacity(contentOpacity)

                Button {
                    HapticManager.tap()
                    onDismiss()
                } label: {
                    Text("Continue")
                        .font(.appButton)
                        .foregroundStyle(Color(red: 0.10, green: 0.62, blue: 0.45))
                        .padding(.vertical, 14)
                        .padding(.horizontal, 40)
                        .background(Color.white, in: Capsule())
                        .shadow(color: .black.opacity(0.25), radius: 10, y: 6)
                }
                .buttonStyle(BouncyButtonStyle())
                .opacity(contentOpacity)
                .padding(.top, 8)
            }
            .padding(40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.55)) {
                starScale = 1.0
                starRotation = 0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.25)) {
                contentOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(0.5)) {
                pulse = true
            }
        }
    }
}
