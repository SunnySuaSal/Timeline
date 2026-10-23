//
//  TrackpadInputview.swift
//  Timeline
//
//  Created by Sunny Suárez Saldaña on 23/10/26.
//


#if os(macOS)

import SwiftUI
import AppKit

struct TrackpadInputView: NSViewRepresentable {

    var onScroll: (CGFloat) -> Void
    var onMagnify: (CGFloat) -> Void

    func makeNSView(context: Context) -> TrackpadNSView {
        let view = TrackpadNSView()

        view.onScroll = onScroll
        view.onMagnify = onMagnify

        return view
    }

    func updateNSView(
        _ nsView: TrackpadNSView,
        context: Context
    ) {
        nsView.onScroll = onScroll
        nsView.onMagnify = onMagnify
    }

    final class TrackpadNSView: NSView {

        var onScroll: ((CGFloat) -> Void)?
        var onMagnify: ((CGFloat) -> Void)?

        override func scrollWheel(with event: NSEvent) {

            let deltaX = event.scrollingDeltaX

            guard abs(deltaX) > 0 else {
                super.scrollWheel(with: event)
                return
            }

            onScroll?(deltaX)
        }

        override func magnify(with event: NSEvent) {

            let factor = max(
                0.01,
                1 + event.magnification
            )

            onMagnify?(factor)
        }
    }
}

#endif
