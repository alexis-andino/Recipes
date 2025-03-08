//
//  UserDefaultsFavoriteRecipesStore.swift
//  Recipes
//
//  Created by Alexis Andino on 3/7/25.
//

import Foundation

protocol FavoriteRecipesStorable {
    func storeFavorites(_ favorites: [String])
    func retrieveFavorites() -> [String]
}

struct UserDefaultsFavoriteRecipesStore: FavoriteRecipesStorable {
    let userDefaults = UserDefaults.standard
    
    private let favoritesKey = "favorites"
    
    func storeFavorites(_ favorites: [String]) {
        userDefaults.set(favorites, forKey: favoritesKey)
    }
    
    func retrieveFavorites() -> [String] {
        userDefaults.array(forKey: favoritesKey) as? [String] ?? []
    }
}
