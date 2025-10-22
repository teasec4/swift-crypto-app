//
//  SupabaseManager.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/13/25.
//
import Foundation
import Supabase


@MainActor
final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        // MARK: - Load configuration safely
        guard
            let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
            let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String,
            let url = URL(string: urlString)
        else {
            fatalError("❌ Supabase configuration missing or invalid in Info.plist")
        }
        
        // MARK: - Initialize client
                client = SupabaseClient(
                    supabaseURL: url,
                    supabaseKey: key
                )
        
        Task {
                    await recoverSessionIfNeeded()
                }
    }
}


// MARK: - Helpers
extension SupabaseManager {

    /// Attempts to restore the previous user session if available
    func recoverSessionIfNeeded() async {
        do {
            let session = try await client.auth.session
            print("✅ Supabase session restored for user:", session.user.email ?? "unknown")
        } catch {
            print("ℹ️ No active Supabase session found or recovery failed:", error.localizedDescription)
        }
    }

    /// Log out and clear session
    func signOut() async {
        do {
            try await client.auth.signOut()
            print("👋 Signed out successfully")
        } catch {
            print("⚠️ Sign-out error:", error.localizedDescription)
        }
    }
}
