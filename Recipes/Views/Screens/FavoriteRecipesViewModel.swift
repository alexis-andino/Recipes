//
//  FavoriteRecipesViewModel.swift
//  Recipes
//
//  Created by Alexis Andino on 3/7/25.
//

import SwiftUI
import Combine

final class FavoriteRecipesViewModel: ObservableObject {
    
    @Published private(set) var favoriteRecipes: [RecipeViewObject] = []
    
    let recipeProvider: any RecipesProvidable
    
    private var cancellables = Set<AnyCancellable>()
    
    init(recipeProvider: any RecipesProvidable) {
        self.recipeProvider = recipeProvider
        observeRecipes()
    }
    
    func unfavorite(recipe: Recipe) {
        Task {
            await recipeProvider.unfavorite(recipe: recipe)
        }
    }
    
    private func observeRecipes() {
        Task {
            await recipeProvider.recipesPublisher
                .receive(on: RunLoop.main)
                .sink { [weak self] in self?.refreshFavoriteRecipes($0) }
                .store(in: &cancellables)
        }
    }
    
    private func refreshFavoriteRecipes(_ updatedRecipes: [RecipeViewObject]) {
        favoriteRecipes = updatedRecipes.filter { $0.isFavorite }
    }
}
