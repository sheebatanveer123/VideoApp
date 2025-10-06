
//  FeedView.swift
//  VideoFeedApp
//
//  Created by Sheeba Tanveer on 2025-10-04.
//

import SwiftUI
import Combine

struct FeedView: View {
    @StateObject private var vm = FeedViewModel()
    @State private var messageText: String = ""
    @State private var page: Int? = 0
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isTextFocused: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if vm.videoURLs.isEmpty {
                ProgressView("Loading…")
                    .foregroundColor(.white)
                    .task { await vm.load() }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(vm.videoURLs.enumerated()), id: \.offset) { idx, _ in
                            VideoCell(index: idx, vm: vm)
                                .frame(width: UIScreen.main.bounds.width,
                                       height: UIScreen.main.bounds.height)
                                .ignoresSafeArea()
                                .id(idx)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollClipDisabled(false)
                .scrollTargetBehavior(.paging)
                .gesture(
                    DragGesture().onEnded { value in
                        let velocity = value.predictedEndTranslation.height - value.translation.height
                        let threshold: CGFloat = 200 // Adjust sensitivity
                        if abs(velocity) > threshold {
                            if velocity < 0 {
                                vm.setCurrentIndex(min(vm.currentIndex + 1, vm.videoURLs.count - 1))
                            } else {
                                vm.setCurrentIndex(max(vm.currentIndex - 1, 0))
                            }
                        }
                    }
                )
                .scrollPosition(id: $page)
                .scrollDisabled(vm.typing) // Disable scroll when typing
                .ignoresSafeArea()
            }
            
            VStack {
                Spacer()
                
                InputBar(text: $messageText, typing: $vm.typing)
                    .padding(.horizontal)
                    .padding(.bottom, keyboardHeight > 0 ? 8 : 30)
            }
            .padding(.bottom, keyboardHeight)
            .animation(.easeOut(duration: 0.25), value: keyboardHeight)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .ignoresSafeArea(.keyboard)
        .onReceive(Publishers.keyboardHeight) { height in
            self.keyboardHeight = height
        }
    }
}

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .map { notification in
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
            }
        
        let willHide = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}
