//
//  RecipesListViewModel.swift
//  Recipes
//
//  Created by Alexis Andino on 3/6/25.
//

import Foundation
import SwiftUI
import Combine

final class RecipesListViewModel: ObservableObject {
    
    @Published private(set) var allRecipes: [RecipeByCuisine] = []
    
    @Published private(set) var listState: RecipesListState = .uninitialized
    
    private let recipesProvider: any RecipesProvidable
    private let emojiFlagService: any EmojiFlagProvidable
    
    private var cancellables = Set<AnyCancellable>()
    
    init(recipesProvider: any RecipesProvidable, emojiFlagService: any EmojiFlagProvidable) {
        self.recipesProvider = recipesProvider
        self.emojiFlagService = emojiFlagService
        observeRecipes()
    }
    
    //MARK: - Public API
    @MainActor
    func refreshAllRecipes() async {
        let previousListState = listState
        do {
            //If we refresh from an already loaded list, this means we are pulling to refresh, in which case we just show the pull to refresh indicator
            if previousListState != .loaded {
                listState = .loading
            }
            
            try await recipesProvider.refreshRecipes()
        } catch is CancellationError {
            //When we use the task modifier, swift can cancel the async call if the view disappears before this operation finishes, this
            //can happen when we navigate from list to details very quickly and it results in the user briefly seeing the error and then loading states. To avoid this we swallow the error and return to the previous state before the update
            listState = previousListState
        } catch {
            listState = .error
        }
    }
    
    func favorite(_ recipe: Recipe) {
        Task {
           await recipesProvider.favorite(recipe: recipe)
        }
    }
    
    func unfavorite(_ recipe: Recipe) {
        Task {
           await recipesProvider.unfavorite(recipe: recipe)
        }
    }
    
    //MARK: - Private API
    //This function keeps our two sets of lists in sync with the remote. When we receive a fresh list from the network we pass it through this function in order to re-categorize allRecipes and to restore any existing favorites.
    private func updateLists(with newRecipes: [RecipeViewObject]) {
        var updatedAllRecipes: [String: [RecipeViewObject]] = [:]
        
        for vo in newRecipes {
            updatedAllRecipes[vo.recipe.cuisine, default: []].append(vo)
        }
        
        allRecipes = updatedAllRecipes.map {
            makeRecipeByCuisine(cuisine: $0.key, recipes: $0.value)
        }.sorted()
        
        listState = newRecipes.isEmpty ? .empty : .loaded
    }
    
    private func makeRecipeByCuisine(cuisine: String, recipes: [RecipeViewObject]) -> RecipeByCuisine {
        let flag = emojiFlagService.emojiFlag(forCuisine: cuisine) ?? ""
        let friendlyDisplayName = "\(flag) \(cuisine)"
        return .init(cuisine: cuisine, friendlyDisplayName: friendlyDisplayName, recipes: recipes)
    }
    
    private func observeRecipes() {
        Task {
            await recipesProvider.recipesPublisher
                .receive(on: RunLoop.main)
                .sink { [weak self] in
                    self?.updateLists(with: $0)
                }.store(in: &cancellables)
           }
       }
}

enum RecipesListState {
    case uninitialized
    case error
    case loading
    case loaded
    case empty
}
