//
//  OnboardingView.swift
//  Storyland
//

import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let gradient: LinearGradient
}

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex = 0

    let onFinish: () -> Void

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            systemImage: "book.pages.fill",
            title: "Welcome to Storyland!",
            subtitle: "Discover the joy of reading with your child through short, colorful stories.",
            gradient: AppTheme.primaryGradient
        ),
        OnboardingPage(
            systemImage: "books.vertical.fill",
            title: "Choose a tale",
            subtitle: "Browse 320 unique stories and pick the one that interests you.",
            gradient: AppTheme.secondaryGradient
        ),
        OnboardingPage(
            systemImage: "speaker.wave.2.fill",
            title: "Listen and read",
            subtitle: "Listen to the narrator, then try to read the text on your own.",
            gradient: LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.61, blue: 0.27),
                    Color(red: 0.96, green: 0.31, blue: 0.51)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        ),
        OnboardingPage(
            systemImage: "questionmark.circle.fill",
            title: "Check understanding",
            subtitle: "Answer questions after each tale and collect stars for completed stories.",
            gradient: AppTheme.successGradient
        ),
        OnboardingPage(
            systemImage: "sparkles",
            title: "Let's begin!",
            subtitle: "All set. Time to dive into Storyland.",
            gradient: LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.36, blue: 0.95),
                    Color(red: 0.96, green: 0.31, blue: 0.51)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    ]

    var body: some View {
        ZStack {
            pages[currentIndex].gradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: currentIndex)

            floatingDecorations

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                TabView(selection: $currentIndex) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                            .padding(.horizontal, 24)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                pageIndicator
                    .padding(.bottom, 24)

                bottomButton
                    .padding(.horizontal, 28)
                    .padding(.bottom, 40)
            }
        }
    }

    private var topBar: some View {
        HStack {
            Spacer()
            if currentIndex < pages.count - 1 {
                Button {
                    HapticManager.tap()
                    finish()
                } label: {
                    Text("Skip")
                        .font(.appCaption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 18)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.45), lineWidth: 1))
                }
            }
        }
        .frame(height: 44)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(Color.white.opacity(currentIndex == index ? 1.0 : 0.35))
                    .frame(width: currentIndex == index ? 26 : 10, height: 10)
                    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: currentIndex)
            }
        }
    }

    private var bottomButton: some View {
        Button {
            HapticManager.tap()
            if currentIndex < pages.count - 1 {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    currentIndex += 1
                }
            } else {
                finish()
            }
        } label: {
            HStack(spacing: 12) {
                Text(currentIndex == pages.count - 1 ? "Let's go" : "Next")
                    .font(.appButton)
                Image(systemName: currentIndex == pages.count - 1 ? "sparkles" : "arrow.right")
                    .font(.title2.weight(.bold))
            }
            .foregroundStyle(pages[currentIndex].gradient)
            .padding(.vertical, 18)
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                    .fill(Color.white)
            )
            .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(BouncyButtonStyle())
    }

    private var floatingDecorations: some View {
        ZStack {
            decorationBubble(size: 90, x: 60, y: 120)
            decorationBubble(size: 50, x: 320, y: 180)
            decorationBubble(size: 70, x: 350, y: 540)
            decorationBubble(size: 40, x: 50, y: 620)
        }
        .allowsHitTesting(false)
    }

    private func decorationBubble(size: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Circle()
            .fill(Color.white.opacity(0.18))
            .frame(width: size, height: size)
            .blur(radius: 6)
            .position(x: x, y: y)
    }

    private func finish() {
        HapticManager.success()
        onFinish()
        dismiss()
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.white.opacity(0.35), Color.white.opacity(0.10)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 180, height: 180)
                    .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 2))

                Image(systemName: page.systemImage)
                    .font(.system(size: 90, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
            }
            .scaleEffect(appeared ? 1.0 : 0.6)
            .opacity(appeared ? 1.0 : 0)

            VStack(spacing: 14) {
                Text(page.title)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.35), radius: 8, y: 3)

                Text(page.subtitle)
                    .font(.appBody)
                    .foregroundStyle(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.3), radius: 6, y: 2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .opacity(appeared ? 1.0 : 0)
            .offset(y: appeared ? 0 : 20)

            Spacer()
            Spacer()
        }
        .onAppear {
            appeared = false
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.1)) {
                appeared = true
            }
        }
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
