//
//  NetworkService.swift
//  Recipes
//
//  Created by Alexis Andino on 3/6/25.
//

import Foundation

class NetworkService {
    
    private let decoder: JSONDecoder
    private let session: URLSession
    private let baseUrl: String
    
    init(baseUrl: String,
         session: URLSession,
         decodingStrategy: JSONDecoder.KeyDecodingStrategy) {
        self.baseUrl = baseUrl
        self.decoder = JSONDecoder()
        self.session = session
        
        decoder.keyDecodingStrategy = decodingStrategy
    }
    
    func fetch<T: Decodable>(request: any ApiRequestable) async throws -> T {
        let urlRequest = try self.urlRequest(from: request)
        let (data, _) = try await session.data(for: urlRequest)
        return try decoder.decode(T.self, from: data)
    }
    
    private func urlRequest(from request: any ApiRequestable) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = baseUrl
        components.path = "/\(request.path)"
        
        guard let url = components.url else {
            assertionFailure("Unable to create URL for \(request.path)")
            throw NSError(domain: "NetworkService", code: 0)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method
        
        return urlRequest
    }
}
