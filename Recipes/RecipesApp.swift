//
//  RecipesApp.swift
//  Recipes
//
//  Created by Alexis Andino on 3/6/25.
//

import SwiftUI

@main
struct RecipesApp: App {
    
    let recipesService = RecipesProvider()
    let imageService = RecipeImageService.shared
    let emojiFlagService = EmojiFlagProvider()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RecipesListView(recipesService: recipesService,
                                recipeImageService: imageService,
                                emojiFlagService: emojiFlagService)
            }
            
            .tint(Color(red: 77/255, green: 182/255, blue: 172/255))
        }
    }
}
