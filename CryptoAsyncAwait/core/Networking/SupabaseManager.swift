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
        // Validate the Supabase URL instead of force-unwrapping it.
        guard let url = URL(string: "https://iccnpikverganvbqgwfk.supabase.co") else {
            preconditionFailure("Invalid Supabase URL - configure Supabase URL in a safe place")
        }

        // NOTE: Consider moving the key out of source control and into secure storage or configuration.
        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImljY25waWt2ZXJnYW52YnFnd2ZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAxMzczMTYsImV4cCI6MjA3NTcxMzMxNn0.SwxhnABDW9OiNcsLXnxXObiQ418Z4yLaXI4T00g9c8E"
        )
    }
}
