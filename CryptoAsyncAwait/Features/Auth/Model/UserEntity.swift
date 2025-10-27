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
    @Attribute(.unique) var id: String
    var email: String
    var name: String?
    
    @Relationship(deleteRule: .cascade, inverse: \UserAsset.user)
    
    init(id: String, email: String, name: String? = nil) {
        self.id = id
        self.email = email
        self.name = name
    }
}
