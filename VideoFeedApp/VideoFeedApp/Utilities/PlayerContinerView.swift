////
////  PlayerContinerView.swift
////  VideoFeedApp
////
////  Created by Sheeba Tanveer on 2025-10-04.
////

import SwiftUI
import AVFoundation

struct PlayerContainerView: UIViewRepresentable {
    let player: AVPlayer?

    func makeUIView(context: Context) -> PlayerView {
        let v = PlayerView()
        v.playerLayer.videoGravity = .resizeAspectFill
        v.backgroundColor = .black
        v.player = player

        if let player = player, let currentItem = player.currentItem {
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: currentItem,
                queue: .main
            ) { _ in
                player.seek(to: .zero)
                player.play()
            }
        }

        return v
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {
        uiView.player = player
    }

    static func dismantleUIView(_ uiView: PlayerView, coordinator: ()) {
        // Clean up observers to prevent leaks
        if let player = uiView.player, let item = player.currentItem {
            NotificationCenter.default.removeObserver(
                self,
                name: .AVPlayerItemDidPlayToEndTime,
                object: item
            )
        }
    }
}

final class PlayerView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
}
