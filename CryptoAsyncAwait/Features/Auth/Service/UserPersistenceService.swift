//
//  UserPersistenceService.swift
//  CryptoAsyncAwait
//
//  Created by AI
//

import Foundation
import SwiftData

/// Protocol для сохранения и загрузки пользователя
protocol UserPersistenceServiceProtocol {
    func saveUser(_ user: UserEntity, context: ModelContext) throws
}

final class UserPersistenceService: UserPersistenceServiceProtocol {
    
    func saveUser(_ user: UserEntity, context: ModelContext) throws {
        let userEmail = user.email
        
        let descriptor = FetchDescriptor<UserEntity>(
            predicate: #Predicate { $0.email == userEmail }
        )
        
        if let existing = try? context.fetch(descriptor).first {
            // Update Supabase ID if it changed
            existing.supabaseId = user.supabaseId
            existing.name = user.name
        } else {
            context.insert(user)
        }
        
        try context.save()
    }
}
