//
//  LoadingModifier.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/15/25.
//

import SwiftUI

struct LoadingModifier: ViewModifier {
    @Binding var isVisible: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isVisible {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .transition(.opacity)

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.yellow.opacity(0.9),
                                        Color.orange.opacity(0.6)
                                    ],
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 50
                                )
                            )
                            .frame(width: 100, height: 100)
                            .shadow(color: .yellow.opacity(0.6), radius: 25)
                            .overlay(
                                Image(systemName: "bitcoinsign.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(20)
                                    .foregroundStyle(.white)
                            )
                            .rotation3DEffect(
                                .degrees(isVisible ? 360 : 0),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .animation(
                                .linear(duration: 1.4)
                                    .repeatForever(autoreverses: false),
                                value: isVisible
                            )
                    }

                    Text("Loading...")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                .padding(.bottom, 60)
                .transition(.opacity)
                .zIndex(10)
            }
        }
    }
}

extension View {
    func contentLoading(isVisible: Binding<Bool>) -> some View {
        modifier(LoadingModifier(isVisible: isVisible))
    }
}
