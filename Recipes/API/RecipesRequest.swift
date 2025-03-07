//
//  RecipesRequest.swift
//  Recipes
//
//  Created by Alexis Andino on 3/6/25.
//


enum RecipesRequest: ApiRequestable {
    case fetchAllRecipes
    
    var path: String {
        switch self {
        case .fetchAllRecipes:
            "recipes.json"
        }
    }
    
    var method: String {
        switch self {
        case .fetchAllRecipes:
            "GET"
        }
    }
}
