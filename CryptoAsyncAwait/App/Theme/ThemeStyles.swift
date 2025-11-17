//
//  ThemeStyles.swift
//  CryptoAsyncAwait
//
//  Created by AI
//

import SwiftUI

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    let theme: ThemeManager
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(AppColors.primary)
            .foregroundColor(.white)
            .cornerRadius(12)
            .fontWeight(.semibold)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    let theme: ThemeManager
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(theme.borderColor)
            .foregroundColor(AppColors.primary)
            .cornerRadius(12)
            .fontWeight(.semibold)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

struct DestructiveButtonStyle: ButtonStyle {
    let theme: ThemeManager
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(AppColors.accentRed.opacity(0.1))
            .foregroundColor(AppColors.accentRed)
            .cornerRadius(12)
            .fontWeight(.semibold)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

// MARK: - TextField Styles

struct AppTextFieldStyle: TextFieldStyle {
    let theme: ThemeManager
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(theme.cardBackground)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(theme.borderColor, lineWidth: 1)
            )
    }
}

// MARK: - Card Styles

struct AppCardStyle: ViewModifier {
    let theme: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(theme.cardBackground)
            .cornerRadius(16)
            .shadow(
                color: Color.black.opacity(theme.isDarkMode ? 0.3 : 0.05),
                radius: 8,
                x: 0,
                y: 2
            )
    }
}

extension View {
    func appCard(_ theme: ThemeManager) -> some View {
        modifier(AppCardStyle(theme: theme))
    }
}

// MARK: - Text Styles

struct AppTitle: ViewModifier {
    let theme: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .font(.title2.weight(.semibold))
            .foregroundColor(theme.textColor)
    }
}

struct AppSubtitle: ViewModifier {
    let theme: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .font(.subheadline.weight(.semibold))
            .foregroundColor(theme.textSecondaryColor)
    }
}

struct AppCaption: ViewModifier {
    let theme: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .foregroundColor(theme.textSecondaryColor)
    }
}

extension Text {
    func appTitle(_ theme: ThemeManager) -> some View {
        modifier(AppTitle(theme: theme))
    }
    
    func appSubtitle(_ theme: ThemeManager) -> some View {
        modifier(AppSubtitle(theme: theme))
    }
    
    func appCaption(_ theme: ThemeManager) -> some View {
        modifier(AppCaption(theme: theme))
    }
}

// MARK: - Section Background

struct SectionBackgroundStyle: ViewModifier {
    let theme: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(theme.cardBackground)
            .cornerRadius(12)
    }
}

extension View {
    func sectionBackground(_ theme: ThemeManager) -> some View {
        modifier(SectionBackgroundStyle(theme: theme))
    }
}
