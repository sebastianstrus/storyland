//
//  StoryDetailView.swift
//  Storyland
//

import SwiftUI

struct StoryDetailView: View {
    let story: Story

    @Environment(SettingsStore.self) private var settings
    @Environment(ProgressStore.self) private var progress
    @Environment(AudioPlayer.self) private var audio
    @Environment(StoryRepository.self) private var repository
    @Environment(\.dismiss) private var dismiss

    @State private var selectedAnswers: [Int: String] = [:]
    @State private var checkShake: CGFloat = 0
    @State private var showCelebration: Bool = false
    @State private var showGrandFinale: Bool = false
    @State private var titleAppeared: Bool = false

    private var allAnswered: Bool {
        story.questions.indices.allSatisfy { selectedAnswers[$0] != nil }
    }

    private var allCorrect: Bool {
        story.questions.enumerated().allSatisfy { index, question in
            selectedAnswers[index] == question.correctAnswer
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.00, green: 0.95, blue: 0.84),
                    Color(red: 1.00, green: 0.88, blue: 0.92),
                    Color(red: 0.88, green: 0.92, blue: 1.00)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    largeImage
                    storyText
                    questions
                    actionFooter
                    Color.clear.frame(height: 24)
                }
                .padding(20)
            }

            if showCelebration {
                CelebrationOverlay {
                    HapticManager.tap()
                    withAnimation(.easeOut(duration: 0.3)) {
                        showCelebration = false
                    }
                    dismiss()
                }
                .transition(.opacity.combined(with: .scale(scale: 1.04)))
            }

            if showGrandFinale {
                GrandFinaleOverlay(totalStories: repository.stories.count) {
                    withAnimation(.easeOut(duration: 0.35)) {
                        showGrandFinale = false
                    }
                    dismiss()
                }
                .transition(.opacity.combined(with: .scale(scale: 1.06)))
                .zIndex(10)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(red: 1.00, green: 0.95, blue: 0.84), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Tale \(story.number)")
                    .font(.appHeadline)
                    .foregroundStyle(Color.black)
            }

            if settings.showPlayButton {
                ToolbarItem(placement: .topBarTrailing) {
                    playButton
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
                titleAppeared = true
            }
        }
        .onDisappear {
            audio.stop()
        }
    }

    private var playButton: some View {
        let isPlayingThis = audio.isPlaying && audio.currentResource == story.audioFileName
        return Button {
            HapticManager.tap()
            audio.toggle(resourceNamed: story.audioFileName)
        } label: {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryGradient)
                    .frame(width: 30, height: 30)
                    .shadow(color: AppTheme.softShadow, radius: 3, y: 1)
                Image(systemName: isPlayingThis ? "pause.fill" : "play.fill")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(.white)
                    .offset(x: isPlayingThis ? 0 : 1)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
        .accessibilityLabel(Text(isPlayingThis ? "Pause audio" : "Play audio"))
    }

    private var header: some View {
        Text(story.title)
            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 30 : 20, weight: .heavy, design: .rounded))
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .opacity(titleAppeared ? 1 : 0)
            .offset(y: titleAppeared ? 0 : 12)
    }

    private var largeImage: some View {
        Image(story.largeImageName)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                    .stroke(Color.white, lineWidth: 4)
            )
            .shadow(color: AppTheme.softShadow, radius: 18, y: 10)
    }

    private var storyText: some View {
        Text(story.text)
            .font(.custom("ChalkboardSE-Regular", size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 18))
            .foregroundStyle(.primary)
            .lineSpacing(6)
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                    .fill(Color.white)
            )
            .shadow(color: AppTheme.softShadow, radius: 10, y: 5)
    }

    private var questions: some View {
        VStack(spacing: 14) {
            ForEach(Array(story.questions.enumerated()), id: \.offset) { index, question in
                QuestionCard(
                    questionNumber: index + 1,
                    totalQuestions: story.questions.count,
                    question: question,
                    selectedOption: binding(for: index)
                )
            }
        }
    }

    private var actionFooter: some View {
        PrimaryButton(
            "Check answers",
            systemImage: "checkmark.seal.fill",
            gradient: AppTheme.primaryGradient
        ) {
            handleCheck()
        }
        .disabled(!allAnswered)
        .opacity(allAnswered ? 1.0 : 0.55)
        .modifier(ShakeEffect(animatableData: checkShake))
        .padding(.top, 8)
    }

    private func binding(for index: Int) -> Binding<String?> {
        Binding(
            get: { selectedAnswers[index] },
            set: { newValue in
                selectedAnswers[index] = newValue
            }
        )
    }

    private func handleCheck() {
        guard allAnswered else { return }

        if allCorrect {
            progress.markCompleted(story.id)
            audio.stop()
            audio.play(resourceNamed: "goodresult")
            HapticManager.celebrate()
            let finishedAll = progress.completedCount == repository.stories.count
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                if finishedAll {
                    showGrandFinale = true
                } else {
                    showCelebration = true
                }
            }
        } else {
            HapticManager.error()
            withAnimation(.linear(duration: 0.45)) {
                checkShake += 1
            }
        }
    }
}

#Preview {
    NavigationStack {
        StoryDetailView(story: Story(
            id: "en1",
            title: "Lily's Magic Garden",
            text: "Lily loved spending time in her grandmother's garden...",
            questions: [
                Question(
                    question: "Where did Lily find the key?",
                    options: ["Under the apple tree", "Under the rose", "In the well", "In the cupboard"],
                    correctAnswer: "Under the rose"
                )
            ]
        ))
        .environment(SettingsStore())
        .environment(ProgressStore())
        .environment(AudioPlayer())
        .environment(StoryRepository())
    }
}
