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
        
        do {
            // Пытаемся загрузить через relationship
            if !user.assets.isEmpty {
                assets = user.assets
                print("✅ Loaded \(assets.count) assets via relationship for: \(user.email)")
                return
            }
            
            // Если relationship пуста, загружаем через поиск
            let all = try context.fetch(FetchDescriptor<UserAsset>())
            assets = all.filter { $0.user?.email == user.email }
            print("✅ Loaded \(assets.count) assets via fetch for: \(user.email)")
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
        
        // Проверяем, есть ли уже этот ассет у пользователя
        if let existingIndex = assets.firstIndex(where: { $0.coin.id == coin.id }) {
            // Обновляем существующий ассет
            assets[existingIndex].amount += amount
            assets[existingIndex].coinPrice = coin.currentPrice
            print("📝 Updated \(coin.name): \(assets[existingIndex].amount) units")
        } else {
            // Создаём новый ассет
            let newAsset = UserAsset(coin: coin, amount: amount, user: user)
            context.insert(newAsset)
            user.assets.append(newAsset)  // ✅ Добавляем в relationship user.assets
            assets.append(newAsset)
            print("➕ Added \(coin.name): \(amount) units to \(user.email)")
            print("   Total assets now: \(user.assets.count)")
        }
        
        do {
            try context.save()
            print("✅ Context saved successfully")
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
            // ✅ Не перезагружаем всё
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
            return
        }
        lastPriceRefreshTime = now
        
        do {
            let ids = assets.map { $0.coinID }
            let prices = try await repository.getSimplePrices(for: ids)
            
            // ✅ Обновляем только цены в локальном массиве
            for index in assets.indices {
                if let newPrice = prices[assets[index].coinID] {
                    assets[index].coinPrice = newPrice
                }
            }
            try context.save()
            // ✅ Не перезагружаем всё
        } catch {
            print("❌ Failed to refresh prices:", error)
        }
    }
    
    /// Принудительное обновление цен (игнорирует дебаунс)
    func forceRefreshAssetPrices(context: ModelContext) async {
        lastPriceRefreshTime = .distantPast
        await refreshAssetPrices(context: context)
    }
    
    // MARK: - Computed
    
    var totalValueUSD: Double {
        assets.reduce(0) { $0 + $1.coin.currentPrice * $1.amount }
    }
}
