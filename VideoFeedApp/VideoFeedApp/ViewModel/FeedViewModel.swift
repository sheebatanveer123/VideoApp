//
//  FeedViewModel.swift
//  VideoFeedApp
//
//  Created by Sheeba Tanveer on 2025-10-04.
//


import Foundation
import AVFoundation

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var videoURLs: [URL] = []
    @Published var currentIndex: Int = 0
    @Published var typing: Bool = false

    let manifestURL = URL(string: "https://cdn.dev.airxp.app/AgentVideos-HLS-Progressive/manifest.json")!
    private let manifestService: ManifestProviding
    let pool = PlayerPool()

    init(manifestService: ManifestProviding = ManifestService()) {
        self.manifestService = manifestService
    }

    func load() async {
        do {
            let manifest = try await manifestService.fetchManifest(from: manifestURL)
            videoURLs = manifest.videos
            pool.prepare(urls: videoURLs, around: currentIndex)
        } catch {
            print("Failed to load manifest: \(error)")
        }
    }

    func onAppearCell(index: Int) {
        pool.prepare(urls: videoURLs, around: index)
        if !typing {
            pool.play(index: index)
        }
    }

    func onDisappearCell(index: Int) {
        pool.pause(index: index)
    }

    func setCurrentIndex(_ newIndex: Int) {
        guard newIndex != currentIndex else { return }
        // Gate page change until next is ready
        if pool.isReady(index: newIndex) || typing {
            pool.pause(index: currentIndex)
            currentIndex = newIndex
            if !typing { pool.play(index: newIndex) }
            pool.prepare(urls: videoURLs, around: newIndex)
        }
    }

    func setTyping(_ isTyping: Bool) {
        typing = isTyping
        if isTyping {
            pool.pause(index: currentIndex)
        } else {
            pool.play(index: currentIndex)
        }
    }
}
