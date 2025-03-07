//
//  CarrotLoadingView.swift
//  Recipes
//
//  Created by Alexis Andino on 3/6/25.
//

import SwiftUI


struct CarrotLoadingView: View {
    @State private var rotation: Double = 0
    
    private var animation: Animation {
            .linear
            .speed(0.3)
            .repeatForever(autoreverses: false)
    }
    
    var body: some View {
        Image(systemName: "carrot.fill")
            .resizable()
            .rotationEffect(.degrees(rotation))
            .onAppear {
                rotation = 0
                withAnimation(animation) {
                    rotation = 360
                }
            }
    }
}
