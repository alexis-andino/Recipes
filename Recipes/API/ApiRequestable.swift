//
//  ApiRequestable.swift
//  Recipes
//
//  Created by Alexis Andino on 3/6/25.
//

protocol ApiRequestable {
    var path: String { get }
    var method: String { get }
}
