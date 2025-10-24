//
//  CustomTabBar.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/22/25.
//
import SwiftUI
import UIKit

struct CustomTabBar: View {
    @Binding var selected: Int
    let icons = ["bitcoinsign.circle", "graph.2d"]
    let titles = ["Coins", "Assets"]
    
    var body: some View {
        HStack {
            ForEach(icons.indices, id: \.self) { index in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selected = index
                    }
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.prepare()
                    generator.impactOccurred()
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: icons[index])
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(selected == index ? Color.black : .gray)
                            
                        
                        Text(titles[index])
                            .font(.caption2)
                            .foregroundColor(selected == index ? .black : .gray)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 6)
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color.white,
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            Rectangle()
                .frame(height: 0.4)
                .foregroundColor(.gray.opacity(0.4))
                .frame(maxHeight: .infinity, alignment: .top)
            , alignment: .top
        )
        .ignoresSafeArea(edges: .bottom) 
    }
}


#Preview{
    ZStack{
        Color(.systemBackground)
            .ignoresSafeArea()
        VStack{
            Spacer()
            CustomTabBar(selected: .constant(0))
        }
    }
}
