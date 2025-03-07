//
//  CardDecorationModifier.swift
//  Recipes
//
//  Created by Alexis Andino on 3/7/25.
//

import SwiftUI

struct CardDecorationModifier: ViewModifier {
    
    let material: Material
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(material)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

extension View {
    func cardBackgroundDecoration(usingMaterial material: Material) -> some View {
        modifier(CardDecorationModifier(material: material))
    }
}
