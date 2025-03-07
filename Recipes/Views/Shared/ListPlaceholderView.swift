//
//  ListPlaceholderView.swift
//  Recipes
//
//  Created by Alexis Andino on 3/6/25.
//

import SwiftUI

struct ListPlaceholderView: View {
    
    let title: String
    let buttonTitle: String
    let buttonAction: () -> Void
    
    var body: some View {
        VStack {
            Image(systemName: "carrot")
                .resizable()
                .frame(width: 200, height: 200)
            Text(title)
            Button(buttonTitle, action: buttonAction)
                .buttonStyle(.borderedProminent)
                .foregroundStyle(.white)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

