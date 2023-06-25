//
//  WebView.swift
//  WebBrowser
//
//  Created by yangjian on 2023/6/19.
//

import Foundation
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let webView: WKWebView
    func makeUIView(context: Context) -> some UIView {
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
