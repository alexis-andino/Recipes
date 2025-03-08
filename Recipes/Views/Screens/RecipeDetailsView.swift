//
//  RecipeDetails.swift
//  Recipes
//
//  Created by Alexis Andino on 3/7/25.
//

import SwiftUI
import WebKit

struct RecipeDetailsView: View {
    
    enum DetailsViewState {
        case uninitialized
        case loading
        case loaded
        case error
    }
    
    let recipe: Recipe
    
    @State private var viewState: DetailsViewState = .uninitialized
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        if let urlString = recipe.sourceUrl, let url = URL(string: urlString) {
            switch viewState {
            case .error:
                errorView
            default:
                webView(forUrl: url)
            }
        } else {
            errorView
        }
    }
        
    private func webView(forUrl url: URL) -> some View {
        WebViewWrapper(url: url, viewState: $viewState)
            .overlay {
                if viewState == .loading {
                    loadingIndicator
                }
            }
            .animation(.default, value: viewState)
    }
    
    private var errorView: some View {
        ListPlaceholderView(title: Constants.noUrlTitle, buttonTitle: Constants.goBackButtonTitle) {
            dismiss()
        }
    }
    
    private var loadingIndicator: some View {
        CarrotLoadingView()
            .foregroundStyle(Color.accentColor)
            .frame(width: 50, height: 50)
    }
}

fileprivate struct WebViewWrapper: UIViewRepresentable {
 
    let url: URL
    
    @Binding var viewState: RecipeDetailsView.DetailsViewState
    
    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        let request = URLRequest(url: url)
        
        view.navigationDelegate = context.coordinator
        view.load(request)
        
        return view
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        //no-op
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebViewWrapper
        
        init(parent: WebViewWrapper) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.viewState = .loading
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.viewState = .loaded
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
            parent.viewState = .error
        }
    }
}


fileprivate enum Constants {
    static let noUrlTitle = "No details found for this recipe 😢"
    static let goBackButtonTitle = "Go back"
}
