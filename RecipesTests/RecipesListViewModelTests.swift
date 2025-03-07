//
//  RecipesListViewModelTests.swift
//  RecipesTests
//
//  Created by Alexis Andino on 3/6/25.
//

import XCTest
@testable import Recipes

final class RecipesListViewModelTests: XCTestCase {
    
    var viewModel: RecipesListViewModel!
    var recipesService: MockRecipesProvider!

    override func setUpWithError() throws {
        recipesService = MockRecipesProvider()
        viewModel = .init(recipesService: recipesService,
                          emojiFlagService: EmojiFlagProvider())
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        recipesService = nil
        viewModel = nil
    }

    func testSuccessfulLoad() async throws {
        recipesService.recipes = [
            .init(cuisine: "American",
                  name: "Banana Pancakes",
                  uuid: "1",
                  photoUrlLarge: nil,
                  photoUrlSmall: nil,
                  sourceUrl: nil,
                  youtubeUrl: nil)
        ]
        recipesService.throwError = false
        
        await viewModel.refreshAllRecipes()
        
        XCTAssertEqual(viewModel.listState, .loaded)
    }
    
    func testErrorLoad() async throws {
        recipesService.throwError = true
        await viewModel.refreshAllRecipes()
        XCTAssertEqual(viewModel.listState, .error)
    }
    
    func testEmptyLoad() async throws {
        recipesService.throwError = false
        recipesService.recipes = []
        await viewModel.refreshAllRecipes()
        XCTAssertEqual(viewModel.listState, .empty)
    }
    
    func testCategorization() async throws {
        recipesService.throwError = false
        recipesService.recipes = getMockRecipes()
        
        await viewModel.refreshAllRecipes()
        
        XCTAssertEqual(viewModel.allRecipes.count, 3)
        XCTAssertEqual(viewModel.allRecipes[0].recipes.count, 3)
        XCTAssertEqual(viewModel.allRecipes[1].recipes.count, 1)
        XCTAssertEqual(viewModel.allRecipes[2].recipes.count, 1)
    }
    
    func testFavoritingRecipe() async throws {
        let mockRecipes = getMockRecipes()
        recipesService.throwError = false
        recipesService.recipes = mockRecipes
        
        await viewModel.refreshAllRecipes()
        
        viewModel.favorite(mockRecipes.first!)
        
        XCTAssertEqual(viewModel.favoriteRecipes.count, 1)
        XCTAssertEqual(viewModel.allRecipes[0].recipes.count, 2)
    }
    
    func testUnfavoritingPro() async throws {
        let mockRecipes = getMockRecipes()
        recipesService.throwError = false
        recipesService.recipes = mockRecipes
        
        await viewModel.refreshAllRecipes()
        
        viewModel.favorite(mockRecipes.first!)
        viewModel.unfavorite(mockRecipes.first!)
        
        XCTAssertEqual(viewModel.favoriteRecipes.count, 0)
        XCTAssertEqual(viewModel.allRecipes[0].recipes.count, 3)
    }
    
    func testFavoritingLastRecipeInList() async throws {
        let recipe =
            Recipe(cuisine: "American",
                  name: "Banana Pancakes",
                  uuid: "1",
                  photoUrlLarge: nil,
                  photoUrlSmall: nil,
                  sourceUrl: nil,
                  youtubeUrl: nil)
        
        recipesService.recipes = [recipe]
        
        await viewModel.refreshAllRecipes()
        
        XCTAssert(viewModel.listState == .loaded)
        
        viewModel.favorite(recipe)
        
        await viewModel.refreshAllRecipes()
        
        XCTAssert(viewModel.listState == .loaded)
        XCTAssertTrue(viewModel.allRecipes.isEmpty)
        XCTAssertEqual(viewModel.favoriteRecipes.count, 1)
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
