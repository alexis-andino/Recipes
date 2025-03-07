//
//  RecipesListView.swift
//  Recipes
//
//  Created by Alexis Andino on 3/6/25.
//

import SwiftUI

struct RecipesListView: View {
    
    @StateObject private var viewModel: RecipesListViewModel
    
    //Used to track transitions between lists
    @Namespace private var animationNamespace
    
    let recipeImageService: any RecipeImageServiceable
    
    init(recipesService: any RecipesProvidable,
         recipeImageService: any RecipeImageServiceable,
         emojiFlagService: any EmojiFlagProvidable) {
        _viewModel = .init(wrappedValue: .init(recipesService: recipesService,
                                               emojiFlagService: emojiFlagService))
        self.recipeImageService = recipeImageService
    }
    
    var body: some View {
        Group {
            switch viewModel.listState {
            case .uninitialized, .empty:
                emptyListView
            case .error:
                errorView
            case .loading:
                loadingView
            case .loaded:
                listView
            }
        }
        .task {
            await viewModel.refreshAllRecipes()
        }
        .animation(.default, value: viewModel.listState)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(red: 255/255, green: 235/255, blue: 153/255).gradient)
        .preferredColorScheme(.light)
    }
    
    private var listView: some View {
        ScrollView {
            VStack(spacing: 32) {
                favoriteRecipesSection
                allRecipesSection
            }
            .padding()
        }
        .refreshable {
            await viewModel.refreshAllRecipes()
        }
        .animation(.default, value: viewModel.favoriteRecipes)
        .animation(.default, value: viewModel.allRecipes)
    }
    
    @ViewBuilder
    private var allRecipesSection: some View {
        VStack(alignment: .leading) {
            Text(Constants.allRecipesSectionTitle)
                .font(.title)
                .fontWeight(.bold)
            allRecipesList
        }
    }
    
    @ViewBuilder
    private var allRecipesList: some View {
        ForEach(viewModel.allRecipes) { cuisine in
            VStack(alignment: .leading) {
                Text(cuisine.friendlyDisplayName)
                    .font(.title3)
                    .fontWeight(.medium)
                ForEach(cuisine.recipes) { recipe in
                    recipeCardView(forRecipe: recipe, isFavorite: false)
                }
            }
            .cardBackgroundDecoration(usingMaterial: .thinMaterial)
        }
    }
    
    @ViewBuilder
    private var favoriteRecipesSection: some View {
        VStack(alignment: .leading) {
            Text(Constants.favoriteRecipesSectionTitle)
                .font(.title)
                .fontWeight(.bold)
            
            VStack {
                if viewModel.favoriteRecipes.isEmpty {
                    favoritesEmptyView
                } else {
                    favoriteRecipesList
                }
            }
            .cardBackgroundDecoration(usingMaterial: .thinMaterial)
        }
    }
    
    @ViewBuilder
    private var favoriteRecipesList: some View {
        ForEach(viewModel.favoriteRecipes) { recipe in
            recipeCardView(forRecipe: recipe, isFavorite: true)
        }
    }
    
    private var favoritesEmptyView: some View {
        VStack(spacing: 16) {
            Text(Constants.noFavoritesText)
                .font(.headline)
            Text(Constants.noFavoritesSubtitle)
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .foregroundStyle(.secondary)
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
    
    private func recipeCardView(forRecipe recipe: Recipe, isFavorite: Bool) -> some View {
        NavigationLink(destination: {
            RecipeDetailsView(recipe: recipe)
        }, label: {
            RecipeCardView(recipe: recipe,
                           isFavorite: isFavorite,
                           recipeImageService: recipeImageService,
                           favoriteAction: {
                if isFavorite {
                    viewModel.unfavorite(recipe)
                } else {
                    viewModel.favorite(recipe)
                }
            })
        })
        .matchedGeometryEffect(id: recipe.id, in: animationNamespace)
    }
}

#Preview {
    RecipesListView(recipesService: RecipesProvider(),
                    recipeImageService: RecipeImageService.shared,
                    emojiFlagService: EmojiFlagProvider())
}

fileprivate enum Constants {
    static let noRecipesFoundText = "No recipes found"
    static let refreshButtonTitle = "Refresh"
    static let errorOccurredText = "An error occurred"
    static let tryAgainButtonTitle = "Try again"
    static let noFavoritesText = "No favorite recipes yet!"
    static let noFavoritesSubtitle = "Try tapping on one of the 🥕 and see what happens!"
    static let allRecipesSectionTitle = "All Recipes"
    static let favoriteRecipesSectionTitle = "Favorite Recipes"
}


