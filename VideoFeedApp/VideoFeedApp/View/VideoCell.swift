////
////  VideoCell.swift
////  VideoFeedApp
////
////  Created by Sheeba Tanveer on 2025-10-04.
////


import SwiftUI
import AVFoundation

struct VideoCell: View {
    let index: Int
    @ObservedObject var vm: FeedViewModel

    private var player: AVPlayer? {
        vm.pool.player(for: index)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let p = player {
                PlayerContainerView(player: p)
                    .ignoresSafeArea()
            }
        }
        .ignoresSafeArea()
        .onAppear { vm.onAppearCell(index: index) }
        .onDisappear { vm.onDisappearCell(index: index) }
    }
}
