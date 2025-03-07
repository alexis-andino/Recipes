//
//  Recipe.swift
//  Recipes
//
//  Created by Alexis Andino on 3/6/25.
//

struct Recipe: Codable {
    let cuisine: String
    let name: String
    let uuid: String
    
    let photoUrlLarge: String?
    let photoUrlSmall: String?
    let sourceUrl: String?
    let youtubeUrl: String?
}

extension Recipe: Identifiable {
    var id: String { uuid }
}

extension Recipe: Equatable {}

struct AllRecipesResponse: Codable {
    let recipes: [Recipe]
}
