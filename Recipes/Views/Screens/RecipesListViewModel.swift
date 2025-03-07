//
//  RecipesListViewModel.swift
//  Recipes
//
//  Created by Alexis Andino on 3/6/25.
//

import Foundation
import SwiftUI

final class RecipesListViewModel: ObservableObject {
    
    @Published private(set) var allRecipes: [RecipeByCuisine] = []
    @Published private(set) var favoriteRecipes: [Recipe] = []
    
    @Published private(set) var listState: RecipesListState = .uninitialized
    
    private let recipesService: any RecipesProvidable
    private let emojiFlagService: any EmojiFlagProvidable
    
    init(recipesService: any RecipesProvidable, emojiFlagService: any EmojiFlagProvidable) {
        self.recipesService = recipesService
        self.emojiFlagService = emojiFlagService
    }
    
    //MARK: - Public API
    @MainActor
    func refreshAllRecipes() async {
        let previousListState = listState
        do {
            //If we refresh from an already loaded list, this means we are pulling to refresh, in which case we just show the pull to refresh indicator
            if listState != .loaded {
                listState = .loading
            }
            
            let updatedRecipes = try await recipesService.fetchAllRecipes()
            updateLists(with: updatedRecipes)
            listState = updatedRecipes.isEmpty ? .empty : .loaded
        } catch is CancellationError {
            //When we use the task modifier, swift can cancel the async call if the view disappears before this operation finishes, this
            //can happen when we navigate from list to details very quickly and it results in the user briefly seeing the error and then loading states. To avoid this we swallow the error and return to the previous state before the update
            listState = previousListState
        } catch {
            listState = .error
        }
    }
    
    func favorite(_ recipe: Recipe) {
        removeRecipeFromAllRecipes(recipe)
        favoriteRecipes.insert(recipe, at: 0)
        recipesService.saveFavoriteRecipe(recipe.id)
    }
    
    func unfavorite(_ recipe: Recipe) {
        favoriteRecipes.removeAll { $0.id == recipe.id }
        insertRecipeToAllRecipes(recipe)
        recipesService.removeFavoriteRecipe(recipe.id)
    }
    
    //MARK: - Private API
    private func removeRecipeFromAllRecipes(_ recipe: Recipe) {
        guard let cuisineIndex = index(forCuisine: recipe.cuisine) else { return }
                                        
        var updatedRecipes = allRecipes[cuisineIndex].recipes
        updatedRecipes.removeAll(where: { $0.id == recipe.id })
        
        if updatedRecipes.isEmpty {
            allRecipes.remove(at: cuisineIndex)
        } else {
            allRecipes[cuisineIndex] = makeRecipeByCuisine(cuisine: recipe.cuisine, recipes: updatedRecipes)
        }
    }
    
    private func insertRecipeToAllRecipes(_ recipe: Recipe) {
        guard let cuisineIndex = index(forCuisine: recipe.cuisine) else {
            allRecipes.append(makeRecipeByCuisine(cuisine: recipe.cuisine, recipes: [recipe]))
            allRecipes.sort()
            return
        }
                            
        var updatedRecipes = allRecipes[cuisineIndex].recipes
        updatedRecipes.append(recipe)
        updatedRecipes.sort(by: { $0.name < $1.name })
        
        allRecipes[cuisineIndex] = makeRecipeByCuisine(cuisine: recipe.cuisine, recipes: updatedRecipes)
    }
    
    private func index(forCuisine cuisine: String) -> Int? {
        allRecipes.firstIndex (where: { $0.cuisine == cuisine })
    }
    
    //This function keeps our two sets of lists in sync with the remote. When we receive a fresh list from the network we pass it through this function in order to re-categorize allRecipes and to restore any existing favorites.
    private func updateLists(with newRecipes: [Recipe]) {
        var updatedAllRecipes: [String: [Recipe]] = [:]
        var updatedFavorites: [Recipe] = []
        
        let savedFavoriteIds = recipesService.fetchFavoriteRecipeIds()
        
        //Preserve order of favorites as they were added instead of reshuffling based on the recipes position in the remote list.
        var favoritesSortOrder: [String: Int] = [:]
        
        for (index, id) in savedFavoriteIds.enumerated() {
            favoritesSortOrder[id] = index
        }
        
        for recipe in newRecipes {
            if savedFavoriteIds.contains(recipe.id) {
                updatedFavorites.append(recipe)
            } else {
                updatedAllRecipes[recipe.cuisine, default: []].append(recipe)
            }
        }
        
        allRecipes = updatedAllRecipes.map {
            makeRecipeByCuisine(cuisine: $0.key, recipes: $0.value)
        }.sorted()
        
        favoriteRecipes = updatedFavorites
            .sorted(by: { favoritesSortOrder[$0.id] ?? 0 > favoritesSortOrder[$1.id] ?? 0})
    }
    
    private func makeRecipeByCuisine(cuisine: String, recipes: [Recipe]) -> RecipeByCuisine {
        let flag = emojiFlagService.emojiFlag(forCuisine: cuisine) ?? ""
        let friendlyDisplayName = "\(flag) \(cuisine)"
        return .init(cuisine: cuisine, friendlyDisplayName: friendlyDisplayName, recipes: recipes)
    }
}

enum RecipesListState {
    case uninitialized
    case error
    case loading
    case loaded
    case empty
}
