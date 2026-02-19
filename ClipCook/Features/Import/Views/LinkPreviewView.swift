import SwiftUI
import LinkPresentation

/// A UIViewRepresentable wrapper for LPLinkView to show rich link previews.
struct LinkPreviewRepresentable: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> LPLinkView {
        let linkView = LPLinkView(url: url)
        // Fetch metadata
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: url) { metadata, error in
            if let metadata {
                DispatchQueue.main.async {
                    linkView.metadata = metadata
                }
            }
        }
        return linkView
    }

    func updateUIView(_ uiView: LPLinkView, context: Context) {}
}
