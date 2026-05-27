//
//  BackgroundVideoView.swift
//  Світ Казок
//

import AVFoundation
import SwiftUI

struct BackgroundVideoView: UIViewRepresentable {
    let resourceName: String
    let fileExtension: String

    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        view.backgroundColor = .black
        if let url = Bundle.main.url(forResource: resourceName, withExtension: fileExtension) {
            view.configure(with: url)
        }
        return view
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {}
}

final class PlayerContainerView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?

    func configure(with url: URL) {
        let item = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer(playerItem: item)
        queuePlayer.isMuted = true
        queuePlayer.actionAtItemEnd = .advance
        looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        playerLayer.player = queuePlayer
        playerLayer.videoGravity = .resizeAspectFill
        player = queuePlayer

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        queuePlayer.play()
    }

    @objc private func appDidBecomeActive() {
        player?.play()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
