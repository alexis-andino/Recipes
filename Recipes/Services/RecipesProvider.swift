//
//  RecipesProvider.swift
//  Recipes
//
//  Created by Alexis Andino on 3/6/25.
//

import Foundation
import SwiftUI
import Combine


protocol RecipesProvidable {
    var recipesPublisher: AnyPublisher<[RecipeViewObject], Never> { get async }
    func refreshRecipes() async throws
    func favorite(recipe: Recipe) async
    func unfavorite(recipe: Recipe) async
}

actor RecipesProvider: RecipesProvidable {

    private(set) var recipes: [RecipeViewObject] = []
    
    private let recipesService: any RecipesServiceable
    private let favoritesStore: any FavoriteRecipesStorable
    
    private var recipesSubject = CurrentValueSubject<[RecipeViewObject], Never>([])
    
    var recipesPublisher: AnyPublisher<[RecipeViewObject], Never> {
        return recipesSubject.eraseToAnyPublisher()
    }
    
    init(recipesService: any RecipesServiceable, favoritesStore: any FavoriteRecipesStorable) {
        self.recipesService = recipesService
        self.favoritesStore = favoritesStore
    }
    
    func refreshRecipes() async throws {
        let newRecipes = try await recipesService.fetchAllRecipes()
        var updatedRecipes: [RecipeViewObject] = []
        
        let savedFavoriteIds = Set(fetchFavoriteRecipeIds())

        for recipe in newRecipes {
            updatedRecipes.append(.init(recipe: recipe, isFavorite: savedFavoriteIds.contains(recipe.id)))
        }
        
        recipes = updatedRecipes
        
        recipesSubject.send(recipes)
    }
    
    func favorite(recipe: Recipe) {
        saveFavoriteRecipe(recipe.id)
        
        guard let index = recipes.firstIndex(where: { $0.recipe.id == recipe.id }) else { return }
        
        recipes[index] = .init(recipe: recipe, isFavorite: true)
                
        recipesSubject.send(recipes)
    }
    
    func unfavorite(recipe: Recipe) {
        removeFavoriteRecipe(recipe.id)
        
        guard let index = recipes.firstIndex(where: { $0.recipe.id == recipe.id }) else { return }
        
        recipes[index] = .init(recipe: recipe, isFavorite: false)
                
        recipesSubject.send(recipes)
    }
    
    private func fetchFavoriteRecipeIds() -> [String] {
        favoritesStore.retrieveFavorites()
    }
    
    private func saveFavoriteRecipe(_ recipeId: String) {
        var currentFavorites = fetchFavoriteRecipeIds()
        
        guard currentFavorites.first(where: { $0 == recipeId}) == nil else {
            return
        }
        
        currentFavorites.append(recipeId)
                
        favoritesStore.storeFavorites(currentFavorites)
    }
    
    private func removeFavoriteRecipe(_ recipeId: String) {
        var favorites = fetchFavoriteRecipeIds()
        favorites.removeAll(where: { $0 == recipeId} )
        favoritesStore.storeFavorites(favorites)
    }
}

