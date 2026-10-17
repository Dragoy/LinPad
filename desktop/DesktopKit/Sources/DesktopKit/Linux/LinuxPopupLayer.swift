import Perception
import SwiftUI
import UIKit

/// A transparent layer over the whole window area that holds Linux popups (menus,
/// combo boxes, tooltips), so they can extend past their window and sit above
/// every other window. Touches anywhere else pass through; a touch outside the
/// open popups also dismisses them, as on other desktops.
final class LinuxPopupLayer: UIView {
    weak var bridge: LinuxGUIBridge?
    private var lastDismissTimestamp: TimeInterval = -1

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        if hit !== self, hit != nil {
            return hit
        }
        // hitTest runs more than once per touch; dismiss once per event.
        if !subviews.isEmpty, let event, event.type == .touches, event.timestamp != lastDismissTimestamp {
            lastDismissTimestamp = event.timestamp
            MainActor.assumeIsolated { bridge?.dismissPopups() }
        }
        return nil
    }

    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        bridge?.hasPopups = true
    }

    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        bridge?.hasPopups = subviews.count > 1
    }
}

/// The layer takes part in hit testing only while a popup is open. iPadOS 16 keeps a hosted
/// UIKit view hit-testable across its whole frame even when its `hitTest` returns nil, so an
/// always-on layer swallowed every touch meant for the windows underneath. While a popup is
/// open there, a touch outside it only dismisses the popup.
struct LinuxPopupLayerHost: View {
    let bridge: LinuxGUIBridge

    var body: some View {
        WithPerceptionTracking {
            LinuxPopupLayerView(bridge: bridge)
                .allowsHitTesting(bridge.hasPopups)
        }
    }
}

private struct LinuxPopupLayerView: UIViewRepresentable {
    let bridge: LinuxGUIBridge

    func makeUIView(context: Context) -> LinuxPopupLayer {
        let layer = LinuxPopupLayer()
        layer.backgroundColor = .clear
        layer.bridge = bridge
        bridge.popupLayer = layer
        return layer
    }

    func updateUIView(_ uiView: LinuxPopupLayer, context: Context) {}
}
