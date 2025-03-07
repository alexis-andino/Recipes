//
//  RecipesProvider.swift
//  Recipes
//
//  Created by Alexis Andino on 3/6/25.
//

import Foundation

protocol RecipesProvidable {
    func fetchAllRecipes() async throws -> [Recipe]
    func fetchFavoriteRecipeIds() -> [String]
    func saveFavoriteRecipe(_ recipeId: String)
    func removeFavoriteRecipe(_ recipeId: String)
}

final class RecipesProvider: RecipesProvidable {
    
    private let networkService: NetworkService
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "favorites"
    
    init() {
        self.networkService = .init(baseUrl: "d3jbb8n5wk0qxi.cloudfront.net",
                                    session: .shared,
                                    decodingStrategy: .convertFromSnakeCase)
    }
    
    func fetchAllRecipes() async throws -> [Recipe] {
        let request = RecipesRequest.fetchAllRecipes
        try await Task.sleep(for: .seconds(2)) //simulate a slow network to see loading state
        let response: AllRecipesResponse = try await networkService.fetch(request: request)
        return response.recipes
    }
    
    func fetchFavoriteRecipeIds() -> [String] {
        userDefaults.array(forKey: favoritesKey) as? [String] ?? []
    }
    
    func saveFavoriteRecipe(_ recipeId: String) {
        var currentFavorites = fetchFavoriteRecipeIds()
        
        guard currentFavorites.first(where: { $0 == recipeId}) == nil else {
            return
        }
        
        currentFavorites.append(recipeId)
        
        userDefaults.set(currentFavorites, forKey: favoritesKey)
    }
    
    func removeFavoriteRecipe(_ recipeId: String) {
        var favorites = fetchFavoriteRecipeIds()
        favorites.removeAll(where: { $0 == recipeId} )
        userDefaults.set(favorites, forKey: favoritesKey)
    }
}
