//
//  StorylandApp.swift
//  Storyland
//

import SwiftUI

@main
struct StorylandApp: App {
    @State private var repository = StoryRepository()
    @State private var progress = ProgressStore()
    @State private var settings = SettingsStore()
    @State private var audio = AudioPlayer()
    @State private var store = StoreManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(repository)
                .environment(progress)
                .environment(settings)
                .environment(audio)
                .environment(store)
                .tint(Color(red: 0.96, green: 0.31, blue: 0.51))
                .preferredColorScheme(.light)
                .environment(\.locale, Locale(identifier: "en"))
                .task {
                    await store.loadProducts()
                }
        }
    }
}
