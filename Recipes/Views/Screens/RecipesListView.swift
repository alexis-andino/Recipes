//
//  RecipesListView.swift
//  Recipes
//
//  Created by Alexis Andino on 3/6/25.
//

import SwiftUI

struct RecipesListView: View {
    
    @StateObject private var viewModel: RecipesListViewModel
    
    let recipeImageService: any RecipeImageServiceable
    
    init(recipesProvider: any RecipesProvidable,
         recipeImageService: any RecipeImageServiceable,
         emojiFlagService: any EmojiFlagProvidable) {
        _viewModel = .init(wrappedValue: .init(recipesProvider: recipesProvider,
                                               emojiFlagService: emojiFlagService))
        self.recipeImageService = recipeImageService
    }
    
    var body: some View {
        Group {
            switch viewModel.listState {
            case .uninitialized, .empty:
                emptyListView
            case .loaded:
                listView
            case .error:
                errorView
            case .loading:
                loadingView
            }
        }
        .animation(.default, value: viewModel.listState)
        .navigationTitle(Constants.navigationTitle)
        .background(Color("MainBackgroundColor").gradient)
    }
    
    private var listView: some View {
        ScrollView {
            VStack {
                allRecipesList
            }
            .padding()
        }
        .refreshable {
            await viewModel.refreshAllRecipes()
        }
        .animation(.default, value: viewModel.allRecipes)
    }
    
    @ViewBuilder
    private var allRecipesList: some View {
        ForEach(viewModel.allRecipes) { cuisine in
            VStack(alignment: .leading) {
                Text(cuisine.friendlyDisplayName)
                    .font(.title3)
                    .fontWeight(.medium)
                ForEach(cuisine.recipes) { recipe in
                    recipeCardView(forRecipe: recipe)
                }
            }
            .cardBackgroundDecoration(usingMaterial: .thinMaterial)
        }
    }
    
    private var emptyListView: some View {
        ListPlaceholderView(title: Constants.noRecipesFoundText,
                            buttonTitle: Constants.refreshButtonTitle) {
            Task { await viewModel.refreshAllRecipes() }
        }
    }
    
    private var errorView: some View {
        ListPlaceholderView(title: Constants.errorOccurredText,
                            buttonTitle: Constants.tryAgainButtonTitle) {
            Task { await viewModel.refreshAllRecipes() }
        }
    }
    
    private var loadingView: some View {
        CarrotLoadingView()
            .frame(width: 100, height: 100)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(Color.accentColor)
    }
    
    private func recipeCardView(forRecipe recipe: RecipeViewObject) -> some View {
        NavigationLink(destination: {
            RecipeDetailsView(recipe: recipe.recipe)
        }, label: {
            RecipeCardView(recipe: recipe.recipe,
                           isFavorite: recipe.isFavorite,
                           recipeImageService: recipeImageService,
                           favoriteAction: {
                if recipe.isFavorite {
                    viewModel.unfavorite(recipe.recipe)
                } else {
                    viewModel.favorite(recipe.recipe)
                }
            })
        })
    }
}

#Preview {
    RecipesListView(recipesProvider: RecipesProvider(recipesService: RecipesService(),
                                                    favoritesStore: UserDefaultsFavoriteRecipesStore()),
                    recipeImageService: RecipeImageService.shared,
                    emojiFlagService: EmojiFlagProvider())
}

fileprivate enum Constants {
    static let noRecipesFoundText = "No recipes found"
    static let refreshButtonTitle = "Refresh"
    static let errorOccurredText = "An error occurred"
    static let tryAgainButtonTitle = "Try again"
    static let navigationTitle = "All Recipes"
}


