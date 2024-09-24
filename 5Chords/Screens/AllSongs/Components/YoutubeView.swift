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
        wkWebViewConfig.allowsAirPlayForMediaPlayback = true

        let wKWebView = WKWebView(frame: UIScreen.main.bounds, configuration: wkWebViewConfig)

        context.coordinator.updateState = { resultUrl in
            videoDidSelected(resultUrl)
            showWebView = false
        }

        wKWebView.configuration.userContentController.add(context.coordinator, name: "clickHandler")
//        let script = """
//                document.addEventListener('click', function(event) {
//                    var currentElement = event.target;
//                    while (currentElement !== null) {
//                        if (currentElement.tagName === 'A') {
//                            break;
//                        }
//                        currentElement = currentElement.parentNode;
//                    }
//                    window.webkit.messageHandlers.clickHandler.postMessage(currentElement.href);
//                });
//        """
        let script = """
            window.addEventListener('click', function(event) {
                if(event.target !== undefined) {
                    var currentElement = event.target;
                    var url = "";
                    do {
                        if(currentElement.tagName === 'A' && "href" in currentElement) {
                            if(currentElement.href.includes("/watch?v=")) {
                                event.stopImmediatePropagation();
                                event.preventDefault();
                                url = currentElement.href;
                                break;
                            }
                        }
                        currentElement = currentElement.parentNode;
                    } while (currentElement !== null)

                    if(url === "") {
                        currentElement = event.target;
                        do {
                            if(currentElement.tagName === 'DIV' && currentElement.id == "dismissible") {
                                event.stopImmediatePropagation();
                                event.preventDefault();
                                for (const child of currentElement.children) {
                                    if(child.tagName === 'YTD-THUMBNAIL') {
                                        for (const grandChild of child.children) {
                                            if(grandChild.tagName === 'A' && grandChild.id == "thumbnail") {
                                                if(grandChild.href.includes("/watch?v=")) {
                                                    url = grandChild.href;
                                                    break;
                                                }
                                            }
                                        }
                                        if(url != "") break;
                                    }
                                }
                                if(url != "") break;
                            }
                            currentElement = currentElement.parentNode;
                        } while (currentElement !== null)
                    }
                    window.webkit.messageHandlers.clickHandler.postMessage(url);
                }
            }, { capture: true });
        """

        wKWebView.configuration.userContentController.addUserScript(
            WKUserScript(
                source: script,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true)
        )

        wKWebView.navigationDelegate = context.coordinator

        return wKWebView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: self.url)
        webView.load(request)
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        return WebViewCoordinator(self)
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
    var url: String
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
        WebView(url: URL(string: url  == "" ? "https://youtube.com" : url)!, showWebView: $showWebView, videoDidSelected: videoDidSelected)
    }
    
}
