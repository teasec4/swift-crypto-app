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
        VStack(spacing: 16) {
            // User info
            Text(authVM.user?.name ?? "No name")
                .font(.headline)
            Text(authVM.user?.email ?? "")
                .foregroundColor(.secondary)

            // Sign Out button
            Button(role: .destructive) {
                withAnimation(.easeInOut) {
                    authVM.signOut()
                }
            } label: {
                Text("Sign Out")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            // Error message
            if let err = authVM.errorMessage {
                Text(err)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
        }
        .padding()
        .frame(maxWidth: 300)
    }
}
