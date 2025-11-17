//
//  AppTheme.swift
//  CryptoAsyncAwait
//
//  Created by AI
//

import SwiftUI
import Combine

// MARK: - Color Palette

struct AppColors {
    // Primary Colors
    static let primary = Color(red: 0.0, green: 0.48, blue: 1.0) // #0078FF
    static let primaryDark = Color(red: 0.0, green: 0.38, blue: 0.85)
    
    // Secondary Colors
    static let accent = Color(red: 0.34, green: 0.76, blue: 0.38) // #56C226 - Green
    static let accentRed = Color(red: 1.0, green: 0.33, blue: 0.33) // #FF5555
    static let accentOrange = Color(red: 1.0, green: 0.59, blue: 0.0) // #FF9600
    
    // Neutral Colors (Light Mode)
    static let lightBackground = Color(red: 0.98, green: 0.98, blue: 1.0) // #FAFAFE
    static let lightCard = Color.white
    static let lightText = Color(red: 0.1, green: 0.1, blue: 0.15) // #1A1A26
    static let lightTextSecondary = Color(red: 0.5, green: 0.5, blue: 0.55) // #808088
    static let lightBorder = Color(red: 0.92, green: 0.92, blue: 0.95) // #EBEBF2
    
    // Neutral Colors (Dark Mode)
    static let darkBackground = Color(red: 0.08, green: 0.08, blue: 0.12) // #141418
    static let darkCard = Color(red: 0.12, green: 0.12, blue: 0.18) // #1F1F2D
    static let darkText = Color(red: 0.98, green: 0.98, blue: 1.0) // #FAFAFE
    static let darkTextSecondary = Color(red: 0.55, green: 0.55, blue: 0.65) // #8C8CA6
    static let darkBorder = Color(red: 0.2, green: 0.2, blue: 0.28) // #333346
}

// MARK: - Theme Manager

@MainActor
final class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode") ||
                          UITraitCollection.current.userInterfaceStyle == .dark
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
    }
    
    // MARK: - Dynamic Colors
    
    var backgroundColor: Color {
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground
    }
    
    var cardBackground: Color {
        isDarkMode ? AppColors.darkCard : AppColors.lightCard
    }
    
    var textColor: Color {
        isDarkMode ? AppColors.darkText : AppColors.lightText
    }
    
    var textSecondaryColor: Color {
        isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary
    }
    
    var borderColor: Color {
        isDarkMode ? AppColors.darkBorder : AppColors.lightBorder
    }
}

// MARK: - Helper View Modifiers

extension View {
    func cardStyle(_ theme: ThemeManager) -> some View {
        self
            .background(theme.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(theme.isDarkMode ? 0.3 : 0.05),
                   radius: 8,
                   x: 0,
                   y: 2)
    }
}
