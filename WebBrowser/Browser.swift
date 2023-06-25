//
//  Browser.swift
//  WebBrowser
//
//  Created by yangjian on 2023/6/19.
//

import Foundation
import WebKit

class Browser: NSObject, ObservableObject {
    init(webView: WKWebView, isSelect: Bool) {
        self.webView = webView
        self.isSelect = isSelect
    }
    @Published var webView: WKWebView
    @Published var isSelect: Bool
    var isNavigation: Bool {
        return webView.url == nil
    }
    
    static func == (lhs: Browser, rhs: Browser) -> Bool {
        return lhs.webView == rhs.webView
    }
    
    static var navigation: Browser {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        return Browser(webView: webView, isSelect: true)
    }
    
    func load(_ url: String) {
        webView.navigationDelegate = self
        if url.isUrl, let Url = URL(string: url) {
            let request = URLRequest(url: Url)
            webView.load(request)
        } else {
            let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let reqString = "https://www.google.com/search?q=" + urlString
            self.load(reqString)
        }
    }
    
    func stopLoad() {
        webView.stopLoading()
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func goForword() {
        webView.goForward()
    }
}

extension Browser:  WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.load(navigationAction.request)
        return nil
    }
}

extension String {
    var isUrl: Bool {
        let url = "[a-zA-z]+://.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", url)
        return predicate.evaluate(with: self)
    }
}
