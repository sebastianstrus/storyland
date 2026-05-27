//
//  SettingsStore.swift
//  Storyland
//

import Foundation

@Observable
final class SettingsStore {
    private let showPlayButtonKey = "showPlayButton"
    private let hasSeenOnboardingKey = "hasSeenOnboarding"

    var showPlayButton: Bool {
        didSet { UserDefaults.standard.set(showPlayButton, forKey: showPlayButtonKey) }
    }

    var hasSeenOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasSeenOnboarding, forKey: hasSeenOnboardingKey) }
    }

    init() {
        if UserDefaults.standard.object(forKey: showPlayButtonKey) == nil {
            UserDefaults.standard.set(true, forKey: showPlayButtonKey)
        }
        self.showPlayButton = UserDefaults.standard.bool(forKey: showPlayButtonKey)
        self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: hasSeenOnboardingKey)
    }
}
