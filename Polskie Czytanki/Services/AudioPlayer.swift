//
//  AudioPlayer.swift
//  Світ Казок
//

import AVFoundation
import Foundation

@MainActor
@Observable
final class AudioPlayer: NSObject {
    private var player: AVAudioPlayer?
    private(set) var isPlaying: Bool = false
    private(set) var currentResource: String?

    override init() {
        super.init()
        configureSession()
    }

    private func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [])
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch {
            print("AVAudioSession configure failed: \(error)")
        }
    }

    func play(resourceNamed name: String, fileExtension: String = "mp3") {
        if currentResource == name, let player {
            player.play()
            isPlaying = true
            return
        }
        stop()
        guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension) else {
            print("Audio not found: \(name).\(fileExtension)")
            return
        }
        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.delegate = self
            newPlayer.prepareToPlay()
            newPlayer.play()
            player = newPlayer
            currentResource = name
            isPlaying = true
        } catch {
            print("Audio play failed: \(error)")
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        currentResource = nil
    }

    func toggle(resourceNamed name: String) {
        if isPlaying && currentResource == name {
            pause()
        } else {
            play(resourceNamed: name)
        }
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isPlaying = false
            self.currentResource = nil
            self.player = nil
        }
    }
}
