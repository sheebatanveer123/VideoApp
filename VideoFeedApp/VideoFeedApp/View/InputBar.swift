////
////  InputBar.swift
////  VideoFeedApp
////
////  Created by Sheeba Tanveer on 2025-10-04.

import SwiftUI

struct InputBar: View {
    @Binding var text: String
    @Binding var typing: Bool
    @State private var internalFocus: Bool = false
    @State private var textHeight: CGFloat = 40
    private let placeholder = "Send message"

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ZStack(alignment: .topLeading) {
                // Background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
                
                // Placeholder
                if text.isEmpty && !internalFocus {
                    Text(placeholder)
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .allowsHitTesting(false)
                }

                AutoGrowingTextView(
                    text: $text,
                    isFocused: $internalFocus,
                    maxLines: 5,
                    onHeightChange: { newHeight in
                        let clampedHeight = min(max(newHeight, 40), 120)
                        if clampedHeight != textHeight {
                            textHeight = clampedHeight
                        }
                    }
                )
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .frame(height: textHeight)
            .animation(.easeInOut(duration: 0.2), value: textHeight)
            
            // Buttons
            if typing {
                if !text.isEmpty {
                    Button {
                        let message = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !message.isEmpty {
                            print("Sending: \(message)")
                        }
                        text = ""
                        internalFocus = false
                        textHeight = 40
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            } else {
                HStack(spacing: 16) {
                    Button {
                        print("Heart tapped")
                    } label: {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.red)
                    }

                    Button {
                        print("Share tapped")
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 22))
                            .foregroundStyle(.white)
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .opacity(0.9)
        )
        .onChange(of: internalFocus) { focus in
            withAnimation(.easeInOut(duration: 0.2)) {
                typing = focus
            }
        }
    }
}

// Preview for testing
struct InputBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            VStack {
                Spacer()
                InputBar(text: .constant(""), typing: .constant(false))
                    .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea()
    }
}
