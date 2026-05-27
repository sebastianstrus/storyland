//
//  HomeView.swift
//  Світ Казок
//

import SwiftUI

struct HomeView: View {
    @Environment(StoryRepository.self) private var repository
    @Environment(ProgressStore.self) private var progress

    @State private var path = NavigationPath()
    @State private var titleAppeared = false
    @State private var bookFloat = false

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                BackgroundVideoView(resourceName: "background_video", fileExtension: "mp4")
                    .ignoresSafeArea()

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.55),
                        Color.black.opacity(0.20),
                        Color.black.opacity(0.70)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                floatingDecorations

                VStack(spacing: 0) {
                    topBar
                        .padding(.horizontal, 20)
                        .padding(.top, 10)

                    titleBlock
                        .padding(.top, 20)

                    Spacer()

                    actionButtons
                        .padding(.horizontal, 28)
                        .padding(.bottom, 60)
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .stories:
                    StoryListView(path: $path)
                case .settings:
                    SettingsView()
                case .story(let story):
                    StoryDetailView(story: story)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                withAnimation(.spring(response: 0.9, dampingFraction: 0.75).delay(0.1)) {
                    titleAppeared = true
                }
                withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                    bookFloat = true
                }
            }
        }
    }

    private var topBar: some View {
        HStack {
            Spacer()
            Button {
                HapticManager.tap()
                path.append(AppRoute.settings)
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(14)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.45), lineWidth: 1))
                    .shadow(color: AppTheme.softShadow, radius: 8, y: 4)
            }
            .accessibilityLabel(Text("Налаштування"))
        }
    }

    private var floatingDecorations: some View {
        ZStack {
            decorationBubble(color: Color.yellow.opacity(0.35), size: 70, x: 40, y: 140)
            decorationBubble(color: Color.pink.opacity(0.30), size: 50, x: 320, y: 200)
            decorationBubble(color: Color.cyan.opacity(0.25), size: 90, x: 340, y: 520)
            decorationBubble(color: Color.purple.opacity(0.30), size: 40, x: 60, y: 600)
        }
        .allowsHitTesting(false)
    }

    private func decorationBubble(color: Color, size: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: 8)
            .position(x: x, y: y)
            .offset(y: bookFloat ? -10 : 10)
    }

    private var titleBlock: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.white.opacity(0.35), Color.white.opacity(0.10)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 130, height: 130)
                    .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 2))

                Image(systemName: "book.pages.fill")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
                    .offset(y: bookFloat ? -6 : 6)
            }
            .scaleEffect(titleAppeared ? 1.0 : 0.5)
            .opacity(titleAppeared ? 1.0 : 0)

            Text("Світ Казок")
                .font(.system(size: 46, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color.yellow.opacity(0.95)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.5), radius: 10, y: 4)
                .multilineTextAlignment(.center)
                .scaleEffect(titleAppeared ? 1.0 : 0.85)
                .opacity(titleAppeared ? 1.0 : 0)

            Text("Відкрий радість читання.")
                .font(.appSubtitle)
                .foregroundStyle(.white.opacity(0.95))
                .shadow(color: .black.opacity(0.5), radius: 6, y: 2)
                .multilineTextAlignment(.center)
                .opacity(titleAppeared ? 1.0 : 0)
        }
        .padding(.horizontal, 24)
    }

    private var actionButtons: some View {
        VStack(spacing: 16) {
            PrimaryButton(
                "Відкрий казки",
                systemImage: "books.vertical.fill"
            ) {
                path.append(AppRoute.stories)
            }

            if progress.completedCount > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("Завершено: \(progress.completedCount) / \(repository.stories.count)")
                        .font(.appCaption.weight(.bold))
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 18)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1))
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(StoryRepository())
        .environment(ProgressStore())
        .environment(SettingsStore())
        .environment(AudioPlayer())
        .environment(StoreManager())
}
