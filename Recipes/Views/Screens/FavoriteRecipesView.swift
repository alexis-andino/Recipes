//
//  FavoriteRecipesView.swift
//  Recipes
//
//  Created by Alexis Andino on 3/7/25.
//

import SwiftUI

struct FavoriteRecipesView: View {
    
    let recipeImageService: any RecipeImageServiceable
    let navigateToAllRecipesAction: () -> Void
    
    @StateObject private var viewModel: FavoriteRecipesViewModel
    
    init(recipeProvider: any RecipesProvidable,
         recipeImageService: any RecipeImageServiceable,
         navigateToAllRecipesAction: @escaping () -> Void) {
        self.recipeImageService = recipeImageService
        self.navigateToAllRecipesAction = navigateToAllRecipesAction
        _viewModel = .init(wrappedValue: .init(recipeProvider: recipeProvider))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                if viewModel.favoriteRecipes.isEmpty {
                    favoritesEmptyView
                } else {
                    favoriteRecipesList
                }
            }
            .cardBackgroundDecoration(usingMaterial: .thinMaterial)
            
            .padding()
        }
        .animation(.default, value: viewModel.favoriteRecipes)
        .background(Color("MainBackgroundColor").gradient)
        .navigationTitle(Constants.navigationTitle)
    }
    
    @ViewBuilder
    private var favoriteRecipesList: some View {
        ForEach(viewModel.favoriteRecipes) { recipe in
            NavigationLink(destination: {
                RecipeDetailsView(recipe: recipe.recipe)
            }, label: {
                RecipeCardView(recipe: recipe.recipe,
                               isFavorite: recipe.isFavorite,
                               recipeImageService: recipeImageService,
                               favoriteAction: {
                    if recipe.isFavorite {
                        viewModel.unfavorite(recipe: recipe.recipe)
                    }
                })
            })
        }
    }
    
    private var favoritesEmptyView: some View {
        VStack(spacing: 16) {
            Text(Constants.noFavoritesText)
                .font(.headline)
            Text(Constants.noFavoritesSubtitle)
                .font(.caption)
            
            Button(Constants.navigateToAllRecipesButtonTitle, action: navigateToAllRecipesAction)
                .buttonStyle(.borderedProminent)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .foregroundStyle(.secondary)
    }
}

fileprivate enum Constants {
    static let navigateToAllRecipesButtonTitle = "View all recipes"
    static let noFavoritesText = "No favorite recipes yet!"
    static let noFavoritesSubtitle = "Try tapping on one of the 🥕 and see what happens!"
    static let navigationTitle = "Favorite Recipes"
}

#Preview {
    FavoriteRecipesView(recipeProvider: RecipesProvider(recipesService: RecipesService(),
                                                        favoritesStore: UserDefaultsFavoriteRecipesStore()),
                        recipeImageService: RecipeImageService.shared,
                        navigateToAllRecipesAction: { })
}
