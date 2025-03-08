//
//  RecipeByCuisine.swift
//  Recipes
//
//  Created by Alexis Andino on 3/6/25.
//

import Foundation

struct RecipeByCuisine: Equatable {
    let cuisine: String
    let friendlyDisplayName: String
    let recipes: [RecipeViewObject]
}

extension RecipeByCuisine: Identifiable {
    var id: String { cuisine }
}

extension RecipeByCuisine: Comparable {
    static func < (lhs: RecipeByCuisine, rhs: RecipeByCuisine) -> Bool {
        lhs.cuisine < rhs.cuisine
    }
}
