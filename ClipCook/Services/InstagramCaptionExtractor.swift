import WebKit

@MainActor
final class InstagramCaptionExtractor: NSObject {

    private var webView: WKWebView?
    private var continuation: CheckedContinuation<String?, Never>?
    private var timeoutTask: Task<Void, Never>?
    private var retryCount = 0

    func extractCaption(from url: URL) async -> String? {
        guard let embedURL = buildEmbedURL(from: url) else { return nil }

        retryCount = 0

        return await withCheckedContinuation { continuation in
            self.continuation = continuation

            let config = WKWebViewConfiguration()
            config.defaultWebpagePreferences.allowsContentJavaScript = true

            let wv = WKWebView(frame: CGRect(x: 0, y: 0, width: 375, height: 812), configuration: config)
            wv.navigationDelegate = self
            self.webView = wv

            wv.load(URLRequest(url: embedURL))

            self.timeoutTask = Task {
                try? await Task.sleep(for: .seconds(15))
                if !Task.isCancelled {
                    self.finish(with: nil)
                }
            }
        }
    }

    func cancel() {
        finish(with: nil)
    }

    // MARK: - URL Handling

    private nonisolated func buildEmbedURL(from url: URL) -> URL? {
        let path = url.path
        guard let regex = try? NSRegularExpression(pattern: #"/(reel|p|tv)/([A-Za-z0-9_-]+)"#),
              let match = regex.firstMatch(
                in: path,
                range: NSRange(path.startIndex..., in: path)
              ),
              let typeRange = Range(match.range(at: 1), in: path),
              let codeRange = Range(match.range(at: 2), in: path) else { return nil }

        let type = String(path[typeRange])
        let code = String(path[codeRange])
        return URL(string: "https://www.instagram.com/\(type)/\(code)/embed/captioned/")
    }

    // MARK: - Extraction

    private func finish(with text: String?) {
        guard let cont = continuation else { return }
        continuation = nil
        timeoutTask?.cancel()
        timeoutTask = nil
        webView?.stopLoading()
        webView?.navigationDelegate = nil
        webView = nil

        let cleaned = text.flatMap { cleanExtractedText($0) }
        cont.resume(returning: cleaned)
    }

    private func attemptExtraction() {
        guard let webView, continuation != nil else { return }

        let js = """
        (function() {
            var el = document.querySelector('.Caption');
            if (el && el.innerText.length > 20) return el.innerText;
            el = document.querySelector('[class*="Caption"]');
            if (el && el.innerText.length > 20) return el.innerText;
            var body = document.body ? document.body.innerText : '';
            return body.length > 50 ? body : '';
        })()
        """

        webView.evaluateJavaScript(js) { [weak self] result, _ in
            Task { @MainActor [weak self] in
                guard let self, self.continuation != nil else { return }
                let text = (result as? String) ?? ""

                if text.count > 30 {
                    self.finish(with: text)
                } else if self.retryCount < 3 {
                    self.retryCount += 1
                    try? await Task.sleep(for: .seconds(2))
                    self.attemptExtraction()
                } else {
                    self.finish(with: text.isEmpty ? nil : text)
                }
            }
        }
    }

    // MARK: - Text Cleanup

    private nonisolated func cleanExtractedText(_ raw: String) -> String? {
        var lines = raw.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }

        let noise = [
            "view more on instagram", "bekijk meer op instagram",
            "log in", "sign up", "add a comment", "liked by",
        ]

        lines = lines.filter { line in
            let lower = line.lowercased()
            if noise.contains(where: { lower.contains($0) }) { return false }
            if lower.hasPrefix("view all") && lower.hasSuffix("comments") { return false }
            if line.range(of: #"^[\d,.]+ likes?$"#, options: [.regularExpression, .caseInsensitive]) != nil { return false }
            if line.range(of: #"^\d+[wdhm]$"#, options: .regularExpression) != nil { return false }
            if line.range(of: #"^\d+\s*(weeks?|days?|hours?|minutes?)\s*ago$"#, options: [.regularExpression, .caseInsensitive]) != nil { return false }
            return true
        }

        // Remove leading username line (short, single word, not starting with a number)
        if let first = lines.first, !first.isEmpty, first.count < 30,
           !first.contains(" "), let ch = first.first, !ch.isNumber {
            lines.removeFirst()
        }

        while lines.last?.isEmpty == true { lines.removeLast() }
        while lines.first?.isEmpty == true { lines.removeFirst() }

        let result = lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        return result.count > 10 ? result : nil
    }
}

// MARK: - WKNavigationDelegate

extension InstagramCaptionExtractor: WKNavigationDelegate {
    nonisolated func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            self.attemptExtraction()
        }
    }

    nonisolated func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: any Error
    ) {
        Task { @MainActor in self.finish(with: nil) }
    }

    nonisolated func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: any Error
    ) {
        Task { @MainActor in self.finish(with: nil) }
    }
}
