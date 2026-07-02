//
//  SwiftUIView.swift
//  TIMER
//
//  Created by Aditya Maroo on 26/12/24.
//

import SwiftUI

struct HelpWebViewController: View {
    @StateObject var model = WebViewModel()
    var body: some View {
        WebView(webView: model.webView)
//            .background(Color.white)
    }
}

#Preview {
    HelpWebViewController()
}
