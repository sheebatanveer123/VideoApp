//
//  PlayerPool.swift
//  VideoFeedApp
//
//  Created by Sheeba Tanveer on 2025-10-04.
//


import Foundation
import AVFoundation
import Network

final class PlayerPool: ObservableObject {
    private var players: [Int: AVPlayer] = [:]
    private var items: [Int: AVPlayerItem] = [:]
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "PlayerPool.Net")
    private var isConstrained: Bool = false

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConstrained = (path.isConstrained || path.isExpensive || path.usesInterfaceType(.cellular))
        }
        monitor.start(queue: queue)
    }

    func player(for index: Int) -> AVPlayer? {
        players[index]
    }

    func prepare(urls: [URL], around index: Int) {
        let window = isConstrained ? 1 : 2
        let wanted = Set((index-window)...(index+window))
        for i in wanted {
            guard i >= 0, i < urls.count else { continue }
            if items[i] == nil {
                let item = AVPlayerItem(url: urls[i])
                if isConstrained {
                    item.preferredPeakBitRate = 1_000_000
                } else {
                    item.preferredPeakBitRate = 5_000_000
                }
                items[i] = item
                let player = AVPlayer(playerItem: item)
                player.actionAtItemEnd = .none
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { _ in
                    player.seek(to: .zero)
                    player.play()
                }
                players[i] = player
            }
        }
        let toEvict = Set(players.keys).subtracting(wanted)
        for i in toEvict {
            if let p = players[i] {
                p.pause()
            }
            players[i] = nil
            items[i] = nil
        }
    }

    func isReady(index: Int) -> Bool {
        guard let item = items[index] else { return false }
        switch item.status {
        case .readyToPlay:
            return item.isPlaybackLikelyToKeepUp || item.loadedTimeRanges.count > 0
        case .failed:
            return false
        case .unknown:
            return false
        @unknown default:
            return false
        }
    }

    func play(index: Int) {
        players[index]?.play()
    }

    func pause(index: Int) {
        players[index]?.pause()
    }
}
