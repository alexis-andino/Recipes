//
//  RecipeCardView.swift
//  Recipes
//
//  Created by Alexis Andino on 3/6/25.
//

import SwiftUI

struct RecipeCardView: View {
    
    let recipe: Recipe
    let isFavorite: Bool
    let recipeImageService: any RecipeImageServiceable
    let favoriteAction: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            image
            VStack(alignment: .leading) {
                Text(recipe.name)
                    .font(.headline)
                if isFavorite {
                    Text(recipe.cuisine)
                        .font(.caption)
                }
            }
            Spacer()
            favoriteButton
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardBackgroundDecoration(usingMaterial: .thickMaterial)
    }
    
    private var image: some View {
        RecipeThumbnailView(recipeThumbnailUrl: URL(string: recipe.photoUrlSmall ?? ""),
                            recipeImageService: recipeImageService)
        
        .frame(width: 100, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var favoriteButton: some View {
        Button(action: favoriteAction) {
            Image(systemName: isFavorite ? "carrot.fill" : "carrot")
                .resizable()
                .frame(width: 25, height: 25)
        }
        .foregroundStyle(isFavorite ? Color.accentColor : Color.gray)
    }
}

#Preview {
    RecipeCardView(recipe: .init(cuisine: "Malaysian",
                                 name: "Apam Balik",
                                 uuid: "1", photoUrlLarge: nil,
                                 photoUrlSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
                                 sourceUrl: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
                                 youtubeUrl: "https://www.youtube.com/watch?v=6R8ffRRJcrg"),
                   isFavorite: true,
                   recipeImageService: RecipeImageService.shared,
                   favoriteAction: { })
}
