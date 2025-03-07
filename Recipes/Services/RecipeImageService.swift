//
//  RecipeImageService.swift
//  Recipes
//
//  Created by Alexis Andino on 3/6/25.
//

import Foundation
import UIKit
import CryptoKit

protocol RecipeImageServiceable {
    func loadImage(forUrl url: URL) async throws -> UIImage?
}

//This class is used to retrieve images from a specified URL. It first attempts to retrieve from an in-memory cache (fast). If this fails, it proceeds to look in the file system (slow) and as a last resource it hits the network.
actor RecipeImageService: RecipeImageServiceable {
    
    static let shared = RecipeImageService()
    
    //We use NSCache here for fast and efficient access to images. This class also comes with other goodies like auto-eviction and thread-safety which prevents it
    //from hogging too much memory so its well-suited for our use case.
    private let inMemoryCache = NSCache<NSURL, UIImage>()
    private let imageDirectoryUrl: URL
    private let urlSession: URLSession = .shared
    
    private init() {
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        imageDirectoryUrl = documentsUrl.appendingPathComponent("RecipeImages")
        
        if !fileManager.fileExists(atPath: imageDirectoryUrl.path()) {
            try? fileManager.createDirectory(at: imageDirectoryUrl, withIntermediateDirectories: true)
        }
    }
    
    func loadImage(forUrl url: URL) async throws -> UIImage? {
        if let cachedImage = fetchImageFromCache(forUrl: url) {            
            return cachedImage
        }
        
        if let diskImage = await getImageFromDisk(forUrl: url) {
            saveImageToCache(image: diskImage, withUrl: url)
            return diskImage
        }
        
        if let networkImage = try await downloadImage(from: url) {
            saveImageToCache(image: networkImage, withUrl: url)
            try await saveImageToDisk(image: networkImage, withUrl: url)
            return networkImage
        }
        
        return nil
    }
    
    private func downloadImage(from url: URL) async throws -> UIImage? {
        let (data, _) = try await urlSession.data(from: url)
        return UIImage(data: data)
    }
    
    private func fetchImageFromCache(forUrl url: URL) -> UIImage? {
        return inMemoryCache.object(forKey: url as NSURL)
    }
    
    private func getImageFromDisk(forUrl url: URL) async -> UIImage? {
        let fileUrl = self.fileUrl(forImageWithUrl: url)
        
        guard let imageData = try? Data(contentsOf: fileUrl) else { return nil }
        
        return UIImage(data: imageData)
    }
    
    private func saveImageToCache(image: UIImage, withUrl url: URL) {
        inMemoryCache.setObject(image, forKey: url as NSURL)
    }
    
    private func saveImageToDisk(image: UIImage, withUrl url: URL) async throws {
        let fileUrl = self.fileUrl(forImageWithUrl: url)
        
        guard let imageData = image.jpegData(compressionQuality: 1) else { return }
        try imageData.write(to: fileUrl)
    }
    
    private func fileUrl(forImageWithUrl url: URL) -> URL {
        let fileName = hashedFileName(forUrl: url)
        return imageDirectoryUrl.appendingPathComponent(fileName)
    }
    
    private func hashedFileName(forUrl url: URL) -> String {
        let hash = SHA256.hash(data: Data(url.absoluteString.utf8))
        return hash.description
    }
}
