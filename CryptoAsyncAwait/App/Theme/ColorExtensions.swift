//
//  ColorExtensions.swift
//  CryptoAsyncAwait
//
//  Created by AI
//

import SwiftUI

extension Color {
    // Primary
    static let appPrimary = AppColors.primary
    static let appPrimaryDark = AppColors.primaryDark
    
    // Accents
    static let appAccent = AppColors.accent
    static let appError = AppColors.accentRed
    static let appWarning = AppColors.accentOrange
}

// Helper for getting dynamic colors from theme
struct DynamicColor {
    let light: Color
    let dark: Color
    
    func color(for isDarkMode: Bool) -> Color {
        isDarkMode ? dark : light
    }
}
