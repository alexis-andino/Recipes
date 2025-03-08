//
//  MockRecipesProvider.swift
//  Recipes
//
//  Created by Alexis Andino on 3/6/25.
//

import Foundation
import Combine
@testable import Recipes

//final class MockRecipesProvider: RecipesProvidable {
//    
//    lazy var recipesPublisher: AnyPublisher<[Recipes.RecipeViewObject], Never> = {
//        PassthroughSubject().eraseToAnyPublisher()
//    }()
//    
//    var recipes: [Recipe] = []
//    var throwError = false
//    
//    private var favoriteRecipeIds: [String] = []
//    
//    func refreshRecipes() async throws {
//        
//    }
//    
//    func favorite(recipe: Recipes.Recipe) async {
//        
//    }
//    
//    func unfavorite(recipe: Recipes.Recipe) async {
//        
//    }
//    
//    func fetchAllRecipes() async throws -> [Recipe] {
//        if throwError {
//            throw NSError(domain: "MockRecipesProvider", code: 0)
//        }
//        
//        return recipes
//    }
//    
//    func fetchFavoriteRecipeIds() -> [String] {
//        favoriteRecipeIds
//    }
//    
//    func saveFavoriteRecipe(_ recipeId: String) {
//        favoriteRecipeIds.append(recipeId)
//    }
//    
//    func removeFavoriteRecipe(_ recipeId: String) {
//        favoriteRecipeIds.removeAll(where: { $0 == recipeId})
//    }
//}

final class MockRecipesService: RecipesServiceable {
    
    var recipes: [Recipe] = []
    var throwError = false
        
    func fetchAllRecipes() async throws -> [Recipes.Recipe] {
        if throwError {
            throw NSError(domain: "MockRecipesProvider", code: 0)
        }
        
        return recipes
    }
}

final class MockFavoritesStore: FavoriteRecipesStorable {
    
    private var favorites: [String] = []
    
    func retrieveFavorites() -> [String] {
        return favorites
    }
    
    func storeFavorites(_ favorites: [String]) {
        self.favorites = favorites
    }
}
