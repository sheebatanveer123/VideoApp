//
//  AutoGrowingTextView.swift
//  VideoFeedApp
//
//  Created by Sheeba Tanveer on 2025-10-04.
//

import SwiftUI
import UIKit

struct AutoGrowingTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    let maxLines: Int
    var onHeightChange: ((CGFloat) -> Void)? = nil
    
    func makeUIView(context: Context) -> DynamicTextView {
        let textView = DynamicTextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .white
        textView.tintColor = .white
        textView.keyboardAppearance = .dark
        textView.returnKeyType = .default
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.maxLines = maxLines
        textView.showsVerticalScrollIndicator = true
        textView.showsHorizontalScrollIndicator = false
        
        return textView
    }
    
    func updateUIView(_ uiView: DynamicTextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
            uiView.adjustHeightAndScroll()
        }

        if text.isEmpty {
            uiView.resetHeight()
        }

        if isFocused && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !isFocused && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
        uiView.onHeightChange = onHeightChange
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: AutoGrowingTextView
        
        init(_ parent: AutoGrowingTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            if let dynamicTextView = textView as? DynamicTextView {
                dynamicTextView.adjustHeightAndScroll()
            }
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isFocused = true
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isFocused = false
        }
    }
}

class DynamicTextView: UITextView {
    var maxLines: Int = 5
    var onHeightChange: ((CGFloat) -> Void)?

    private var maxHeight: CGFloat {
        guard let font = font else { return 100 }
        let lineHeight = font.lineHeight
        return (lineHeight * CGFloat(maxLines)) + textContainerInset.top + textContainerInset.bottom
    }

    private var minHeight: CGFloat {
        guard let font = font else { return 30 }
        return font.lineHeight + 8
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        isScrollEnabled = false
        alwaysBounceVertical = false
        showsVerticalScrollIndicator = false
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    override var intrinsicContentSize: CGSize {
        let textSize = sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
        if textSize.height < minHeight {
            return CGSize(width: UIView.noIntrinsicMetric, height: minHeight)
        } else if textSize.height > maxHeight {
            return CGSize(width: UIView.noIntrinsicMetric, height: maxHeight)
        } else {
            return textSize
        }
    }

    func adjustHeightAndScroll() {
        let textSize = sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
        let shouldScroll = textSize.height > maxHeight

        // Height callback before animation
        onHeightChange?(min(max(textSize.height, minHeight), maxHeight))

        // Enable scrolling only after 5 lines
        isScrollEnabled = shouldScroll
        showsVerticalScrollIndicator = shouldScroll

        // Scroll automatically to the bottom as the user types
        if shouldScroll {
            let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.height + contentInset.bottom)
            setContentOffset(bottomOffset, animated: false)
        }

        UIView.animate(withDuration: 0.15) {
            self.invalidateIntrinsicContentSize()
            self.superview?.layoutIfNeeded()
        }
    }

    func resetHeight() {
        text = ""
        isScrollEnabled = false
        showsVerticalScrollIndicator = false
        invalidateIntrinsicContentSize()
        frame.size.height = minHeight
        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()
    }
}
