//
//  AuthViewModel.swift
//  CryptoAsyncAwait
//
//  Created by Max Kovalev on 13/10/2025.
//
import Foundation
import Supabase
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: UserEntity?
    @Published var isLoading = false
    @Published var errorMessage: String?
    var lastAuthUpdate: Date?
    
    private let client = SupabaseManager.shared.client
    private var authTask: Task<Void, Never>?
    
    init() {
        // get user
        Task{ [weak self] in
            if let u = client.auth.currentUser {
                user = UserEntity(
                    id: u.id.uuidString,
                    email: u.email ?? "",
                    name: u.userMetadata["name"]?.stringValue
                )
            }
        }
        

        authTask = Task { [weak self] in
                guard let self else { return }
                var lastAuthUpdate: Date?
                
                for await (event, session) in await client.auth.authStateChanges {
                    guard Date().timeIntervalSince(lastAuthUpdate ?? .distantPast) > 1 else { continue }
                    lastAuthUpdate = Date()
                    
                    switch event {
                    case .initialSession, .signedIn:
                        if let u = session?.user {
                            self.user = UserEntity(
                                id: u.id.uuidString,
                                email: u.email ?? "",
                                name: u.userMetadata["name"]?.stringValue
                            )
                        }
                    case .signedOut:
                        self.user = nil
                    default:
                        break
                    }
                }
            }
    }
    
    deinit {
        authTask?.cancel()
    }
    
    // MARK: - Sign Up
    func signUp(name: String, email: String, password: String) async {
        await handle {
            let resp = try await client.auth.signUp(
                email: email,
                password: password,
                data: ["name": AnyJSON.string(name)]
            )
            let u = resp.user
            return UserEntity(
                id: u.id.uuidString,
                email: u.email ?? "",
                name: u.userMetadata["name"]?.stringValue
            )
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        Task.detached(priority: .userInitiated) {
            do {
                let session = try await self.client.auth.signIn(email: email, password: password)
                let u = session.user
                await MainActor.run {
                    self.user = UserEntity(
                        id: u.id.uuidString,
                        email: u.email ?? "",
                        name: u.userMetadata["name"]?.stringValue
                    )
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        
        user = nil
        errorMessage = nil

        Task {
            do {
                try await client.auth.signOut()
            } catch {
                print("Sign out failed:", error.localizedDescription)
            }
        }
    }
    
    // MARK: - Helper
    private func handle(_ op: () async throws -> UserEntity) async {
        isLoading = true
        errorMessage = nil
        do   { self.user = try await op() }
        catch { self.errorMessage = error.localizedDescription }
        isLoading = false
    }
}
