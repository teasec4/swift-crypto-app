//
//  AssetsViewModel.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/24/25.
//

import SwiftUI
import Combine
import SwiftData
import Foundation

@MainActor
final class AssetsViewModel: ObservableObject {
    @Published private(set) var assets: [UserAsset] = []
    @Published var currentUser: UserEntity?
    

    // initiate repo
    private let repository: CoinRepositoryProtocol
    
    init(repository: CoinRepositoryProtocol = DependencyContainer.shared.coinRepository) {
        self.repository = repository
    }
    
    
    /// Загружает ассеты для текущего пользователя
    func loadAssets(context: ModelContext) {
        guard let user = currentUser else {
            print("⚠️ No current user set, cannot load assets")
            assets = []
            return
        }
        
        do {
            let all = try context.fetch(FetchDescriptor<UserAsset>())
            assets = all.filter { $0.user?.id == user.id }
        } catch {
            print("❌ Failed to load assets:", error)
            assets = []
        }
    }
    
    /// Добавляет новый ассет или увеличивает количество существующего (только для текущего пользователя)
    func addAsset(coin: Coin, amount: Double, context: ModelContext) throws {
        guard amount > 0 else { return }
        guard let user = currentUser else {
            print("⚠️ No current user set, cannot add asset")
            return
        }
        
        // Проверяем, есть ли уже этот ассет у пользователя
        if let existing = user.assets.first(where: { $0.coin.id == coin.id }) {
            existing.amount += amount
        } else {
            let newAsset = UserAsset(coin: coin, amount: amount, user: user)
            context.insert(newAsset)
            user.assets.append(newAsset)
        }
        
        try context.save()
        loadAssets(context: context)
    }
    
    /// Обновляет количество существующего ассета
    func updateAsset(_ asset: UserAsset, newAmount: Double, context: ModelContext) throws {
        guard newAmount >= 0 else { return }
        guard let user = currentUser else { return }
        guard asset.user?.id == user.id else { return }  // безопасность
        
        if let index = assets.firstIndex(where: { $0.id == asset.id }) {
            assets[index].amount = newAmount
            try context.save()
            loadAssets(context: context)
        }
    }
    
    /// Удаляет ассет по ID (только для текущего пользователя)
    func removeAsset(withId id: UUID, context: ModelContext) throws {
        guard let user = currentUser else { return }
        
        if let asset = assets.first(where: { $0.id == id && $0.user?.id == user.id }) {
            context.delete(asset)
            try context.save()
            loadAssets(context: context)
        }
    }
    
    /// Полностью очищает все ассеты текущего пользователя
    func clearAllAssets(context: ModelContext) throws {
        guard let user = currentUser else { return }
        
        for asset in user.assets {
            context.delete(asset)
        }
        try context.save()
        assets.removeAll()
    }
    
    /// Обновляет цены ассетов текущего пользователя
    func refreshAssetPrices(context: ModelContext) async {
        guard let user = currentUser else { return }
        guard !user.assets.isEmpty else { return }
        
        do {
            let ids = user.assets.map { $0.coinID }
            let prices = try await repository.getSimplePrices(for: ids)
            
            for a in user.assets {
                if let newPrice = prices[a.coinID] {
                    a.coinPrice = newPrice
                }
            }
            try context.save()
            loadAssets(context: context)
        } catch {
            print("❌ Failed to refresh prices:", error)
        }
    }
    
    // MARK: - Computed
    
    var totalValueUSD: Double {
        assets.reduce(0) { $0 + $1.coin.currentPrice * $1.amount }
    }
}
