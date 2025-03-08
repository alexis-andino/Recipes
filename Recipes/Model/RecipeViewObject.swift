//
//  RecipeViewObject.swift
//  Recipes
//
//  Created by Alexis Andino on 3/7/25.
//
import Foundation

struct RecipeViewObject: Equatable, Identifiable {
    let recipe: Recipe
    let isFavorite: Bool
    var id: String { recipe.id }
}
