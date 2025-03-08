//
//  RecipesService.swift
//  Recipes
//
//  Created by Alexis Andino on 3/7/25.
//

import Foundation

protocol RecipesServiceable {
    func fetchAllRecipes() async throws -> [Recipe]
}

final class RecipesService: RecipesServiceable {
    private let networkService: NetworkService
    
    init() {
        self.networkService = .init(baseUrl: "d3jbb8n5wk0qxi.cloudfront.net",
                                    session: .shared,
                                    decodingStrategy: .convertFromSnakeCase)
    }
    
    func fetchAllRecipes() async throws -> [Recipe] {
        let request = RecipesRequest.fetchAllRecipes
        try await Task.sleep(for: .seconds(2)) //simulate a slow network to see loading state
        let response: AllRecipesResponse = try await networkService.fetch(request: request)
        return response.recipes
    }
}
