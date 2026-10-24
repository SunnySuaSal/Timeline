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

    // MARK: - Native AppKit View

    final class TrackpadNSView: NSView {

        var onScroll: ((CGFloat) -> Void)?
        var onMagnify: ((CGFloat) -> Void)?

        private var scrollMonitor: Any?

        // MARK: - View Lifecycle

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()

            removeScrollMonitor()

            guard window != nil else {
                return
            }

            installScrollMonitor()
        }

        deinit {
            removeScrollMonitor()
        }

        // MARK: - Event Monitor

        private func installScrollMonitor() {

            scrollMonitor = NSEvent.addLocalMonitorForEvents(
                matching: .scrollWheel
            ) { [weak self] event in

                guard let self,
                      let window = self.window,
                      event.window === window else {
                    return event
                }

                // Current pointer location in window coordinates.
                let mouseLocation =
                    window.mouseLocationOutsideOfEventStream

                // Convert to this view's local coordinates.
                let localPoint = self.convert(
                    mouseLocation,
                    from: nil
                )

                // Only respond inside the timeline area.
                guard self.bounds.contains(localPoint) else {
                    return event
                }

                let deltaX = event.scrollingDeltaX

                guard abs(deltaX) > 0 else {
                    return event
                }

                self.onScroll?(deltaX)

                // Preserve normal event delivery.
                return event
            }
        }

        // MARK: - Monitor Cleanup

        private func removeScrollMonitor() {

            if let scrollMonitor {
                NSEvent.removeMonitor(scrollMonitor)
                self.scrollMonitor = nil
            }
        }

        // MARK: - Magnification

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
