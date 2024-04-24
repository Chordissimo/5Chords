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
        let wKWebView = WKWebView()
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
                            // Return the first anchor element found
                            break;
                        }
                        // Move to the parent node
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
        
//        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//            print("didCommit")
//        }
//        
//        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//            print("didStartProvisionalNavigation")
//        }
        
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
        WebView(url: URL(string: "https://youtube.com")!, showWebView: $showWebView, videoDidSelected: videoDidSelected)
    }
    
}

//#Preview {
//    YoutubeView()
//}
