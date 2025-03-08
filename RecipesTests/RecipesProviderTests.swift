//
//  RecipesProviderTests.swift
//  RecipesTests
//
//  Created by Alexis Andino on 3/7/25.
//

import XCTest
@testable import Recipes

final class RecipesProviderTests: XCTestCase {
    
    var favoritesStore: MockFavoritesStore!
    var recipesService: MockRecipesService!
    var recipesProvider: RecipesProvider!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        favoritesStore = MockFavoritesStore()
        recipesService = MockRecipesService()
        recipesProvider = RecipesProvider(recipesService: recipesService, favoritesStore: favoritesStore)
    }

    override func tearDownWithError() throws {
        favoritesStore = nil
        recipesService = nil
        recipesProvider = nil
    }

    func testRefreshing() async throws {
        recipesService.recipes = getMockRecipes()
        var count = await recipesProvider.recipes.count
        XCTAssertEqual(count, 0)
        
        try await recipesProvider.refreshRecipes()
        count = await recipesProvider.recipes.count
        
        XCTAssertEqual(count, 5)
    }
    
    func testFavorite() async throws {
        recipesService.recipes = getMockRecipes()
        try await recipesProvider.refreshRecipes()
        
        var firstRecipe = await recipesProvider.recipes[0]
        
        await recipesProvider.favorite(recipe: firstRecipe.recipe)
        
        firstRecipe = await recipesProvider.recipes[0]
        
        XCTAssertTrue(firstRecipe.isFavorite)
        XCTAssertTrue(favoritesStore.retrieveFavorites()[0] == firstRecipe.id)
    }
    
    func testUnfavorite() async throws {
        recipesService.recipes = getMockRecipes()
        try await recipesProvider.refreshRecipes()
        
        var firstRecipe = await recipesProvider.recipes[0]
        
        await recipesProvider.favorite(recipe: firstRecipe.recipe)
        await recipesProvider.unfavorite(recipe: firstRecipe.recipe)
        
        firstRecipe = await recipesProvider.recipes[0]
        
        XCTAssertFalse(firstRecipe.isFavorite)
        XCTAssertTrue(favoritesStore.retrieveFavorites().isEmpty)
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
