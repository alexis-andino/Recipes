//
//  EmojiFlagProvider.swift
//  Recipes
//
//  Created by Alexis Andino on 3/7/25.
//


protocol EmojiFlagProvidable {
    func emojiFlag(forCuisine cuisine: String) -> String?
}

class EmojiFlagProvider: EmojiFlagProvidable {
    //While this is not an exhaustive list, it can easily be extended to contain all flags.
    private let mappings: [String: String] = [
        "American": "🇺🇸",
        "British": "🇬🇧",
        "Canadian": "🇨🇦",
        "Croatian": "🇭🇷",
        "French": "🇫🇷",
        "Greek": "🇬🇷",
        "Italian": "🇮🇹",
        "Malaysian": "🇲🇾",
        "Polish": "🇵🇱",
        "Portuguese": "🇵🇹",
        "Russian": "🇷🇺",
        "Tunisian": "🇹🇳"
        ]
    
    func emojiFlag(forCuisine cuisine: String) -> String? {
        mappings[cuisine]
    }
}
