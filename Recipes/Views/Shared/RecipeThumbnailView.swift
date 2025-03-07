//
//  RecipeThumbnailView.swift
//  Recipes
//
//  Created by Alexis Andino on 3/6/25.
//

import SwiftUI
import UIKit


//We get this functionality for free using AsyncImage but we created a custom one for academic purposes
struct RecipeThumbnailView: View {
    
    enum ViewState {
        case uninitialized
        case error
        case loaded(UIImage)
    }
    
    let recipeThumbnailUrl: URL?
    let recipeImageService: any RecipeImageServiceable
    
    @State private var viewState: ViewState = .uninitialized
    
    var body: some View {
        switch viewState {
        case .uninitialized:
            ProgressView()
                .task {
                    await loadImage()
                }
        case .error:
            errorView
        case .loaded(let image):
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        }
    }
    
    private var errorView: some View {
        Image(systemName: "fork.knife")
    }
    
    private func loadImage() async {
        guard let recipeThumbnailUrl else {
            viewState = .error
            return
        }
        
        do {
            guard let image = try await recipeImageService.loadImage(forUrl: recipeThumbnailUrl) else {
                viewState = .error
                return
            }
            viewState = .loaded(image)
        } catch {
            viewState = .error
        }
    }
}

#Preview {
    RecipeThumbnailView(recipeThumbnailUrl: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg")!,
                        recipeImageService: RecipeImageService.shared)
}
