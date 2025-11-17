//
//  CustomTabBar.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/22/25.
//
import SwiftUI
import UIKit

struct NavigationTabBar: View {
    @Binding var selected: Int
    @EnvironmentObject var themeManager: ThemeManager
    
    private let icons = ["bitcoinsign.circle", "briefcase.fill", "person.fill"]
    private let titles = ["Markets", "Portfolio", "Profile"]
    
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
                            .foregroundColor(selected == index ? AppColors.primary : themeManager.textSecondaryColor)
                        
                        Text(titles[index])
                            .font(.caption2)
                            .foregroundColor(selected == index ? AppColors.primary : themeManager.textSecondaryColor)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 6)
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .background(themeManager.cardBackground)
        .overlay(
            Rectangle()
                .frame(height: 0.4)
                .foregroundColor(themeManager.borderColor)
                .frame(maxHeight: .infinity, alignment: .top),
            alignment: .top
        )
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    ZStack {
        Color(.systemBackground)
            .ignoresSafeArea()
        VStack {
            Spacer()
            NavigationTabBar(selected: .constant(0))
        }
    }
}
