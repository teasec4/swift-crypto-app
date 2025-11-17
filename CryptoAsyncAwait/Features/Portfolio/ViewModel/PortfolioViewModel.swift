//
//  PortfolioViewModel.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев
//

import SwiftUI
import Combine
import SwiftData
import Foundation

@MainActor
final class PortfolioViewModel: ObservableObject {
    @Published private(set) var assets: [UserAsset] = [] {
        didSet {
            objectWillChange.send()
        }
    }
    @Published var currentUser: UserEntity?
    
    private let repository: CoinRepositoryProtocol
    private let validator: AssetValidatorProtocol
    
    // Дебаунс для обновления цен
    private var lastPriceRefreshTime: Date = .distantPast
    private let priceRefreshMinInterval: TimeInterval = 60 // минимум 60 сек между обновлениями
    
    init(
        repository: CoinRepositoryProtocol = DependencyContainer.shared.coinRepository,
        validator: AssetValidatorProtocol = AssetValidator()
    ) {
        self.repository = repository
        self.validator = validator
    }
    
    
    /// Загружает ассеты для текущего пользователя
    func loadAssets(context: ModelContext) {
        guard let user = currentUser else {
            print("⚠️ No current user set, cannot load assets")
            assets = []
            return
        }
        
        print("📥 loadAssets for: \(user.email)")
        
        do {
            // ✅ Загружаем через relationship (самый надёжный способ)
            print("   Fetching from user.assets relationship...")
            let relationshipAssets = user.assets
            print("   Found \(relationshipAssets.count) assets in relationship")
            
            assets = relationshipAssets
            
            if assets.isEmpty {
                print("⚠️ No assets found for: \(user.email)")
            } else {
                print("✅ Loaded \(assets.count) assets for: \(user.email)")
            }
        } catch {
            print("❌ Failed to load assets:", error)
            assets = []
        }
    }
    
    /// Добавляет новый ассет или увеличивает количество существующего (только для текущего пользователя)
    func addAsset(coin: Coin, amount: Double, context: ModelContext) throws {
        guard validator.validateAmount(amount) else { 
            print("❌ Invalid amount: \(amount)")
            return 
        }
        guard let user = currentUser else {
            print("❌ No current user set, cannot add asset")
            return
        }
        
        print("💾 addAsset called for \(user.email): \(coin.name) x\(amount)")
        print("   User ID: \(user.supabaseId)")
        print("   Current assets count before: \(user.assets.count)")
        
        // Проверяем, есть ли уже этот ассет у пользователя
        if let existingIndex = assets.firstIndex(where: { $0.coin.id == coin.id }) {
            // Обновляем существующий ассет
            assets[existingIndex].amount += amount
            assets[existingIndex].coinPrice = coin.currentPrice
            print("📝 Updated \(coin.name): \(assets[existingIndex].amount) units")
        } else {
            // Создаём новый ассет
            let newAsset = UserAsset(coin: coin, amount: amount, user: user)
            print("   Created new asset: \(newAsset.id)")
            context.insert(newAsset)
            user.assets.append(newAsset)  // ✅ Добавляем в relationship user.assets
            assets.append(newAsset)
            print("➕ Added \(coin.name): \(amount) units to \(user.email)")
            print("   Total assets now: \(user.assets.count)")
        }
        
        do {
            try context.save()
            print("✅ Context saved successfully")
            print("   Assets in DB: \(user.assets.count)")
        } catch {
            print("❌ Failed to save context: \(error)")
            throw error
        }
    }
    
    /// Обновляет количество существующего ассета
    func updateAsset(_ asset: UserAsset, newAmount: Double, context: ModelContext) throws {
        guard newAmount >= 0 else { return }
        guard let user = currentUser else { return }
        guard validator.validateUserOwnership(asset, user: user) else { return }
        
        if let index = assets.firstIndex(where: { $0.id == asset.id }) {
            assets[index].amount = newAmount  // ✅ Обновляем локально
            try context.save()
        }
    }
    
    /// Удаляет ассет по ID (только для текущего пользователя)
    func removeAsset(withId id: UUID, context: ModelContext) throws {
        guard let user = currentUser else { return }
        
        if let index = assets.firstIndex(where: { $0.id == id && validator.validateUserOwnership($0, user: user) }) {
            let asset = assets[index]
            context.delete(asset)
            try context.save()
            assets.remove(at: index)  // ✅ Удаляем из локального массива
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
    
    /// Обновляет цены ассетов текущего пользователя (с дебаунсом)
    func refreshAssetPrices(context: ModelContext) async {
        guard let user = currentUser else { return }
        guard !assets.isEmpty else { return }
        
        // ✅ Дебаунс: не обновляем чаще, чем раз в 60 секунд
        let now = Date()
        guard now.timeIntervalSince(lastPriceRefreshTime) > priceRefreshMinInterval else {
            print("⏳ Price refresh skipped (debounced)")
            return
        }
        lastPriceRefreshTime = now
        
        do {
            let ids = assets.map { $0.coinID }
            print("🔄 Fetching prices for \(ids.count) coins...")
            let prices = try await repository.getSimplePrices(for: ids)
            
            // ✅ Обновляем только цены в локальном массиве с валидацией
            var updated = false
            for index in assets.indices {
                if let newPrice = prices[assets[index].coinID], newPrice > 0 {
                    assets[index].coinPrice = newPrice
                    updated = true
                }
            }
            
            // ✅ Принудительно отправляем обновление если что-то изменилось
            if updated {
                objectWillChange.send()
            }
            
            try context.save()
            print("✅ Asset prices updated and saved")
        } catch {
            print("❌ Failed to refresh prices:", error)
        }
    }
    
    /// Принудительное обновление цен (игнорирует дебаунс) - для pull-to-refresh
    /// Бросает ошибку если обновление не удалось
    func forceRefreshAssetPrices(context: ModelContext) async throws {
        guard !assets.isEmpty else {
            print("⚠️ No assets to refresh")
            return
        }
        
        print("🔄 Force refreshing asset prices...")
        lastPriceRefreshTime = .distantPast
        
        do {
            let ids = assets.map { $0.coinID }
            print("🔄 Fetching prices for \(ids.count) coins...")
            let prices = try await repository.getSimplePrices(for: ids)
            
            // ✅ Обновляем только цены в локальном массиве с валидацией
            var updated = false
            for index in assets.indices {
                if let newPrice = prices[assets[index].coinID], newPrice > 0 {
                    assets[index].coinPrice = newPrice
                    updated = true
                }
            }
            
            // ✅ Принудительно отправляем обновление если что-то изменилось
            if updated {
                objectWillChange.send()
            }
            
            try context.save()
            print("✅ Asset prices updated and saved")
        } catch {
            print("❌ Failed to refresh prices:", error)
            throw error // ✅ Пробрасываем ошибку вверх
        }
    }
    
    // MARK: - Computed
    
    var totalValueUSD: Double {
        assets.reduce(0) { $0 + $1.coin.currentPrice * $1.amount }
    }
}
