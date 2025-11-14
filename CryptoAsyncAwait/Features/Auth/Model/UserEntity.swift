//
//  UserEntity.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/2/25.
//

import Foundation
import SwiftData

@Model
final class UserEntity{
    @Attribute(.unique) var email: String
    var supabaseId: String
    var name: String?
    
    @Relationship(deleteRule: .cascade, inverse: \UserAsset.user)
    var assets: [UserAsset] = []
    
    init(supabaseId: String, email: String, name: String? = nil) {
        self.supabaseId = supabaseId
        self.email = email
        self.name = name
    }
}
