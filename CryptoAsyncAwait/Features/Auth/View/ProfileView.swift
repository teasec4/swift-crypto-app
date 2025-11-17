//
//  ProfileView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/13/25.
//
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header with avatar
                        VStack(spacing: 16) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [AppColors.primary, AppColors.primaryDark]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                Text(initials)
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 100, height: 100)
                            
                            // Name and email
                            VStack(spacing: 6) {
                                Text(authVM.user?.name ?? "User")
                                    .font(.title2.weight(.semibold))
                                    .foregroundColor(themeManager.textColor)
                                
                                Text(authVM.user?.email ?? "")
                                    .font(.callout)
                                    .foregroundColor(themeManager.textSecondaryColor)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .cardStyle(themeManager)
                        
                        // Stats section
                        VStack(spacing: 12) {
                            HStack(spacing: 16) {
                                StatCard(
                                    icon: "calendar",
                                    title: "Member Since",
                                    value: "Oct 2025",
                                    theme: themeManager
                                )
                                StatCard(
                                    icon: "checkmark.circle.fill",
                                    title: "Status",
                                    value: "Active",
                                    valueColor: .green,
                                    theme: themeManager
                                )
                            }
                        }
                        .padding(.horizontal, 4)
                        
                        // Settings section
                        VStack(spacing: 0) {
                            SettingsRowWithToggle(
                                icon: "moon.stars.fill",
                                title: "Dark Mode",
                                isOn: $themeManager.isDarkMode,
                                theme: themeManager
                            )
                            
                            Divider()
                                .padding(.leading, 48)
                            
                            SettingsRow(
                                icon: "bell.badge",
                                title: "Notifications",
                                subtitle: "Manage alerts",
                                theme: themeManager
                            )
                            
                            Divider()
                                .padding(.leading, 48)
                            
                            SettingsRow(
                                icon: "lock.fill",
                                title: "Security",
                                subtitle: "Password & 2FA",
                                theme: themeManager
                            )
                            
                            Divider()
                                .padding(.leading, 48)
                            
                            SettingsRow(
                                icon: "doc.text",
                                title: "Terms & Privacy",
                                subtitle: "Legal information",
                                theme: themeManager
                            )
                        }
                        .cardStyle(themeManager)
                        
                        Spacer()
                            .frame(height: 16)
                        
                        // Sign Out button
                        Button(role: .destructive) {
                            withAnimation(.easeInOut) {
                                authVM.signOut()
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrowrturn.left")
                                Text("Sign Out")
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(AppColors.accentRed.opacity(0.1))
                            .foregroundColor(AppColors.accentRed)
                            .cornerRadius(12)
                            .fontWeight(.semibold)
                        }
                        
                        // Error message
                        if let err = authVM.errorMessage {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(AppColors.accentRed)
                                Text(err)
                                    .font(.footnote)
                                Spacer()
                            }
                            .foregroundColor(AppColors.accentRed)
                            .padding(12)
                            .background(AppColors.accentRed.opacity(0.1))
                            .cornerRadius(8)
                            .transition(.opacity)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
    }
    
    private var initials: String {
        let name = authVM.user?.name ?? "U"
        return name.split(separator: " ")
            .map { String($0.prefix(1)) }
            .joined()
            .uppercased()
    }
}

// MARK: - Components

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = AppColors.primary
    let theme: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(AppColors.primary)
                    .font(.system(size: 14))
                Text(title)
                    .font(.caption)
                    .foregroundColor(theme.textSecondaryColor)
                Spacer()
            }
            
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(valueColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(theme.borderColor.opacity(0.5))
        .cornerRadius(10)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let theme: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(theme.textColor)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(theme.textSecondaryColor)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(theme.textSecondaryColor)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
    }
}

struct SettingsRowWithToggle: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    let theme: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primary)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(theme.textColor)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
    }
}
