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
    let icons = ["bitcoinsign.circle", "person.fill"]
    let titles = ["Coins", "Profile"]
    
    var body: some View {
        HStack {
            ForEach(icons.indices, id: \.self) { index in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selected = index
                    }
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.prepare()
                    generator.impactOccurred()
                } label: {
                    VStack(spacing: 4) {
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
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .padding(.bottom, 6)
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
        .ignoresSafeArea(edges: .bottom) // 🔹 важное место
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
