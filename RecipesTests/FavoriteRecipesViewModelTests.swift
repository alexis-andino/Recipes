//
//  FavoriteRecipesViewModelTests.swift
//  Recipes
//
//  Created by Alexis Andino on 3/7/25.
//


//
//  RecipesListViewModelTests.swift
//  RecipesTests
//
//  Created by Alexis Andino on 3/6/25.
//

import XCTest
import Combine
@testable import Recipes

final class FavoriteRecipesViewModelTests: XCTestCase {
    
    var viewModel: FavoriteRecipesViewModel!
    
    var favoritesStore: MockFavoritesStore!
    var recipesService: MockRecipesService!
    var recipesProvider: RecipesProvider!
    
    var cancellables: Set<AnyCancellable> = []
    
    override func setUpWithError() throws {
        recipesService = MockRecipesService()
        favoritesStore = MockFavoritesStore()
        recipesProvider = RecipesProvider(recipesService: recipesService,
                                          favoritesStore: favoritesStore)
        viewModel = .init(recipeProvider: recipesProvider)
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        favoritesStore = nil
        recipesService = nil
        viewModel = nil
    }
    
    func testInitialLoadWithExistingFavorite() async throws {
        recipesService.recipes = getMockRecipes()
        recipesService.throwError = false
        favoritesStore.storeFavorites(["1", "5"])
                        
        let expectation = XCTestExpectation(description: "Favorite recipes should update")
        
        viewModel.$favoriteRecipes
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }.store(in: &cancellables)
        
        try await recipesProvider.refreshRecipes()
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(viewModel.favoriteRecipes.count, 2)
    }
    
    
    private func getMockRecipes() -> [Recipe] {
        [
            .init(cuisine: "American",
                  name: "Banana Pancakes",
                  uuid: "1",
                  photoUrlLarge: nil,
                  photoUrlSmall: nil,
                  sourceUrl: nil,
                  youtubeUrl: nil),
            .init(cuisine: "American",
                  name: "Chocolate Raspberry Brownies",
                  uuid: "2",
                  photoUrlLarge: nil,
                  photoUrlSmall: nil,
                  sourceUrl: nil,
                  youtubeUrl: nil),
            .init(cuisine: "American",
                  name: "Key Lime Pie",
                  uuid: "3",
                  photoUrlLarge: nil,
                  photoUrlSmall: nil,
                  sourceUrl: nil,
                  youtubeUrl: nil),
            .init(cuisine: "Canadian",
                  name: "BeaverTails",
                  uuid: "4",
                  photoUrlLarge: nil,
                  photoUrlSmall: nil,
                  sourceUrl: nil,
                  youtubeUrl: nil),
            .init(cuisine: "British",
                  name: "Blackberry Fool",
                  uuid: "5",
                  photoUrlLarge: nil,
                  photoUrlSmall: nil,
                  sourceUrl: nil,
                  youtubeUrl: nil)
        ]
    }
}
