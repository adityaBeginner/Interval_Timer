//
//  WebViewStruct.swift
//  TIMER
//
//  Created by Aditya Maroo on 26/12/24.
//

import Foundation
import SwiftUI
import WebKit

enum WebUrl: String, CaseIterable{
    case Resoource = "https://www.pbintervals.app/resources"
    case Tutorial = "https://www.pbintervals.app/tutorials-ios"
    case PrivacyPolicy = "https://www.pbintervals.app/privacy-policy-ios"
}


struct WebView: UIViewRepresentable {
    typealias UIViewType = WKWebView

    let webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
}

class WebViewModel: ObservableObject {
    let webView: WKWebView
    let url: URL
//    var isCsvUrl: Bool = false
    
    init(allUrl: WebUrl = .PrivacyPolicy) {
        webView = WKWebView(frame: .zero)
        url = URL(string: allUrl.rawValue)!
        loadUrl()
    }
    
    func loadUrl() {
        webView.load(URLRequest(url: url))
    }
}
