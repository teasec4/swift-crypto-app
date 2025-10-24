//
//  UserAsset.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/24/25.
//
import Foundation

struct UserAsset: Identifiable, Hashable {
    let id = UUID()
    let coin: Coin
    var amount: Double
    
}
