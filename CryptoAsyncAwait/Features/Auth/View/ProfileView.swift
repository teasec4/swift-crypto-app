//
//  ProfileView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/13/25.
//
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationStack {
            
                VStack{
                    
                    // User Info Card
                    VStack(spacing: 16) {
                        VStack(spacing: 6) {
                            Text(authVM.user?.name ?? "User")
                                .font(.title2.weight(.semibold))
                                .foregroundColor(.primary)
                            
                            Text(authVM.user?.email ?? "")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        // Stats
                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text("Member Since")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Oct 2025")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 4) {
                                Text("Account Status")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                    Text("Active")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    Spacer()
                    
                    // Sign Out button
                    Button(role: .destructive) {
                        withAnimation(.easeInOut) {
                            authVM.signOut()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrowrturn.left")
                            Text("Sign Out")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                        .padding(.bottom, 40)
                    }
                    
                    // Error message
                    if let err = authVM.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            Text(err)
                                .font(.footnote)
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.red.opacity(0.08))
                        .cornerRadius(8)
                        .transition(.opacity)
                    }
                    
                }
                .padding(20)
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
            
            
        }
    }
    
    private var initials: String {
        let name = authVM.user?.name ?? "U"
        return name.split(separator: " ")
            .map { String($0.prefix(1)) }
            .joined()
            .uppercased()
    }
}
