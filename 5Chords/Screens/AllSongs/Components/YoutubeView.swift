//
//  YoutubeView.swift
//  AmDm AI
//
//  Created by Marat Zainullin on 20/04/2024.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var url: URL
    @Binding var showWebView: Bool
    var videoDidSelected: (_ resultUrl: String) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let wkWebViewConfig = WKWebViewConfiguration()
        wkWebViewConfig.allowsInlineMediaPlayback = true
        let wKWebView = WKWebView(frame: UIScreen.main.bounds, configuration: wkWebViewConfig)
        context.coordinator.updateState = { resultUrl in
            videoDidSelected(resultUrl)
            showWebView = false
        }
        wKWebView.configuration.userContentController.add(context.coordinator, name: "clickHandler")
        let script = """
                document.addEventListener('click', function(event) {
                    var currentElement = event.target;
                    while (currentElement !== null) {
                        if (currentElement.tagName === 'A') {
                            break;
                        }
                        currentElement = currentElement.parentNode;
                    }
                    window.webkit.messageHandlers.clickHandler.postMessage(currentElement.href);
                });
        """
        wKWebView.configuration.userContentController.addUserScript(WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true))
        wKWebView.navigationDelegate = context.coordinator
        
        return wKWebView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(self)
    }
    
    class WebViewCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView
        var updateState: ((_ resultUrl: String) -> Void)?
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "clickHandler", let urlString = message.body as? String, urlString.contains("watch?v=") {
                self.updateState?(urlString)
            }
        }
        
    }
}

struct YoutubeView: View {
    @Binding var showWebView: Bool
    var videoDidSelected: (_ resultUrl: String) -> Void

    var body: some View {
        HStack {
            ActionButton(imageName: "chevron.left", title: "Back") {
                showWebView = false
            }
            .frame(height: 18)
            .font(.system( size: 18))
            .padding(.vertical, 10)
            .padding(.horizontal,5)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        WebView(url: URL(string: "https://youtube.com")!, showWebView: $showWebView, videoDidSelected: videoDidSelected)
    }
    
}
