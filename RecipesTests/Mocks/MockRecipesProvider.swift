//
//  MockRecipesProvider.swift
//  Recipes
//
//  Created by Alexis Andino on 3/6/25.
//

import Foundation
@testable import Recipes

final class MockRecipesProvider: RecipesProvidable {
 
    var recipes: [Recipe] = []
    var throwError = false
    
    private var favoriteRecipeIds: [String] = []
    
    func fetchAllRecipes() async throws -> [Recipe] {
        if throwError {
            throw NSError(domain: "MockRecipesProvider", code: 0)
        }
        
        return recipes
    }
    
    func fetchFavoriteRecipeIds() -> [String] {
        favoriteRecipeIds
    }
    
    func saveFavoriteRecipe(_ recipeId: String) {
        favoriteRecipeIds.append(recipeId)
    }
    
    func removeFavoriteRecipe(_ recipeId: String) {
        favoriteRecipeIds.removeAll(where: { $0 == recipeId})
    }
}
