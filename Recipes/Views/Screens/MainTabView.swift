//
//  MainTabView.swift
//  Recipes
//
//  Created by Alexis Andino on 3/7/25.
//

import SwiftUI

struct MainTabView: View {
    
    let recipeProvider: any RecipesProvidable
    let recipeImageService: any RecipeImageServiceable
    let emojiFlagService: any EmojiFlagProvidable
    
    @State private var selectedTab = 0
    @State private var isLoading = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            allRecipes
            favoriteRecipes
        }        
        .preferredColorScheme(.light)
        .task {
            Task {
                do {
                    isLoading = true
                    try await recipeProvider.refreshRecipes()
                    isLoading = false
                } catch {
                    isLoading = false
                }
            }
        }.overlay {
            if isLoading {
                loadingOverlay
            }
        }
        .animation(.default, value: isLoading)
    }
    
    private var allRecipes: some View {
        NavigationStack {
            RecipesListView(recipesProvider: recipeProvider,
                            recipeImageService: recipeImageService,
                            emojiFlagService: emojiFlagService)
        }.tabItem {
            Label("All Recipes", systemImage: "fork.knife.circle.fill")
        }
        .tag(0)
    }
    
    private var favoriteRecipes: some View {
        NavigationStack {
            FavoriteRecipesView(recipeProvider: recipeProvider,
                                recipeImageService: recipeImageService,
                                navigateToAllRecipesAction: navigateToAllRecipesAction)
        }
        .tabItem {
            Label("Favorites", systemImage: "carrot.fill")
        }
        .tag(1)
    }
    
    private var loadingOverlay: some View {
        CarrotLoadingView()
            .foregroundStyle(Color.accentColor)
            .frame(width: 100, height: 100) //Carrot size
            .frame(maxWidth: .infinity, maxHeight: .infinity) //Cover the entire screen
            .background(Color("MainBackgroundColor").gradient)
    }
    
    private func navigateToAllRecipesAction() {
        selectedTab = 0
    }
}
