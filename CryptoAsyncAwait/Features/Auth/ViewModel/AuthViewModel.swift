//
//  AuthViewModel.swift
//  CryptoAsyncAwait
//
//  Created by Max Kovalev on 13/10/2025.
//
import Foundation
import Supabase
import Combine
import SwiftData

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: UserEntity?
    @Published var isLoading = false
    @Published var errorMessage: String?
    var lastAuthUpdate: Date?
    
    private let client = SupabaseService.shared.client
    private let persistenceService: UserPersistenceServiceProtocol
    private var authTask: Task<Void, Never>?
    
    init(persistenceService: UserPersistenceServiceProtocol = UserPersistenceService()) {
        self.persistenceService = persistenceService
        setupAuthStateListener()
    }
    
    deinit {
        authTask?.cancel()
    }
    
    // MARK: - Setup Auth State Listener
    
    private func setupAuthStateListener() {
        authTask = Task { [weak self] in
            guard let self else { return }
            var lastAuthUpdate: Date?
            
            for await (event, session) in await client.auth.authStateChanges {
                guard Date().timeIntervalSince(lastAuthUpdate ?? .distantPast) > 1 else { continue }
                lastAuthUpdate = Date()
                
                switch event {
                case .initialSession, .signedIn:
                    if let u = session?.user {
                        print("🔐 Auth state changed: signed in as \(u.email ?? "unknown")")
                        // Не создаём здесь юзера, это будет в signIn() или restoreUser()
                    }
                case .signedOut:
                    self.user = nil
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - Sign Up
    
    func signUp(name: String, email: String, password: String, context: ModelContext) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let resp = try await client.auth.signUp(
                email: email,
                password: password,
                data: ["name": AnyJSON.string(name)]
            )
            let u = resp.user
            let localUser = UserEntity(
                supabaseId: u.id.uuidString,
                email: u.email ?? "",
                name: u.userMetadata["name"]?.stringValue
            )
            
            // ✅ Сохраняем в локальную БД
            try persistenceService.saveUser(localUser, context: context)
            self.user = localUser
            print("✅ User signed up and saved: \(localUser.email)")
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Sign up failed: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Sign In
    
    func signIn(email: String, password: String, context: ModelContext) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await client.auth.signIn(email: email, password: password)
            let u = session.user
            let supabaseEmail = u.email ?? ""
            
            // ✅ Загружаем или создаём локального юзера
            let localUser = try getOrCreateLocalUser(
                supabaseId: u.id.uuidString,
                email: supabaseEmail,
                name: u.userMetadata["name"]?.stringValue,
                context: context
            )
            
            self.user = localUser
            print("✅ User signed in: \(localUser.email)")
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Sign in failed: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Restore User (при запуске приложения)
    
    func restoreUserFromDatabase(context: ModelContext) {
        guard let supabaseUser = client.auth.currentUser else {
            print("⚠️ No Supabase session found")
            return
        }
        
        let supabaseEmail = supabaseUser.email ?? ""
        
        do {
            let localUser = try getOrCreateLocalUser(
                supabaseId: supabaseUser.id.uuidString,
                email: supabaseEmail,
                name: supabaseUser.userMetadata["name"]?.stringValue,
                context: context
            )
            self.user = localUser
            print("✅ Restored user from database: \(localUser.email)")
        } catch {
            print("❌ Failed to restore user: \(error)")
        }
    }
    
    // MARK: - Get or Create Local User
    
    /// Загружает существующего пользователя или создаёт нового в локальной БД
    private func getOrCreateLocalUser(
        supabaseId: String,
        email: String,
        name: String?,
        context: ModelContext
    ) throws -> UserEntity {
        print("🔍 getOrCreateLocalUser: \(email)")
        
        // ✅ Пытаемся найти по email (уникальный)
        let descriptor = FetchDescriptor<UserEntity>(
            predicate: #Predicate { $0.email == email }
        )
        
        if let existingUser = try context.fetch(descriptor).first {
            print("📥 Found existing user in database: \(email)")
            print("   Assets count: \(existingUser.assets.count)")
            return existingUser
        }
        
        // ✅ Если не найден, создаём нового
        print("   User not found, creating new...")
        let newUser = UserEntity(
            supabaseId: supabaseId,
            email: email,
            name: name
        )
        context.insert(newUser)
        try context.save()
        print("➕ Created new user in database: \(email)")
        
        return newUser
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        user = nil
        errorMessage = nil
        
        Task {
            do {
                try await client.auth.signOut()
                print("✅ Signed out")
            } catch {
                print("❌ Sign out failed:", error.localizedDescription)
            }
        }
    }
}
