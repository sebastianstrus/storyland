//
//  ProgressStore.swift
//  Світ Казок
//

import Foundation

@Observable
final class ProgressStore {
    private let defaultsKey = "completedStoryIds"
    private(set) var completedIds: Set<String> = []

    init() {
        load()
    }

    func isCompleted(_ storyId: String) -> Bool {
        completedIds.contains(storyId)
    }

    func markCompleted(_ storyId: String) {
        guard !completedIds.contains(storyId) else { return }
        completedIds.insert(storyId)
        persist()
    }

    func resetAll() {
        completedIds.removeAll()
        persist()
    }

    var completedCount: Int { completedIds.count }

    private func load() {
        if let array = UserDefaults.standard.array(forKey: defaultsKey) as? [String] {
            completedIds = Set(array)
        }
    }

    private func persist() {
        UserDefaults.standard.set(Array(completedIds), forKey: defaultsKey)
    }
}
