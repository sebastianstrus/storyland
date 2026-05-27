//
//  ContentView.swift
//  Storyland
//

import SwiftUI

struct ContentView: View {
    @Environment(SettingsStore.self) private var settings
    @State private var showOnboarding = false

    var body: some View {
        HomeView()
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView {
                    settings.hasSeenOnboarding = true
                }
            }
            .onAppear {
                if !settings.hasSeenOnboarding {
                    showOnboarding = true
                }
            }
    }
}

#Preview {
    ContentView()
        .environment(StoryRepository())
        .environment(ProgressStore())
        .environment(SettingsStore())
        .environment(AudioPlayer())
        .environment(StoreManager())
}
