//
//  RecipesApp.swift
//  Recipes
//
//  Created by Alexis Andino on 3/6/25.
//

import SwiftUI

@main
struct RecipesApp: App {
    
    let recipesProvider = RecipesProvider(recipesService: RecipesService(),
                                         favoritesStore: UserDefaultsFavoriteRecipesStore())
    let imageService = RecipeImageService.shared
    let emojiFlagService = EmojiFlagProvider()
    
    var body: some Scene {
        WindowGroup {
            MainTabView(recipeProvider: recipesProvider,
                        recipeImageService: imageService,
                        emojiFlagService: emojiFlagService)
        }
    }
}
