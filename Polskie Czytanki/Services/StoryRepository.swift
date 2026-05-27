//
//  StoryRepository.swift
//  Storyland
//

import Foundation

@Observable
final class StoryRepository {
    private(set) var stories: [Story] = []

    init() {
        loadStories()
    }

    private func loadStories() {
        guard let url = Bundle.main.url(forResource: "stories_en", withExtension: "json") else {
            assertionFailure("stories_en.json missing from bundle")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let payload = try JSONDecoder().decode(StoriesPayload.self, from: data)
            stories = payload.stories
        } catch {
            assertionFailure("Failed to decode stories: \(error)")
        }
    }
}
