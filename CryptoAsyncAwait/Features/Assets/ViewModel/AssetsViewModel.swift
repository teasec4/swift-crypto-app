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
final class AssetsViewModel: ObservableObject{
    @Published private(set) var assets: [UserAsset] = []
    @Published var selectedCoin: Coin? = nil
    @Published var inputAmount: String = ""
    @Published var showAddSheet = false
    @Published var formMode: AssetFormMode? = nil
    @Published var currentUser: UserEntity?
    
    private let repository: CoinRepositoryProtocol
    
    init(repository: CoinRepositoryProtocol = DependencyContainer.shared.coinRepository) {
            self.repository = repository
        }
    
    
    enum AssetFormMode {
        case add
        case edit(UserAsset)
    }
    
    /// Loads assets for the specified user from the given ModelContext.
    func loadAssets(for user: UserEntity, context: ModelContext) {
        do {
                let fetched = try context.fetch(FetchDescriptor<UserAsset>())
                assets = fetched.filter { $0.user?.id == user.id }
            } catch {
                print("Failed to load assets: \(error)")
                assets = []
            }
    }
    
    /// Adds a new asset for the specified user into the ModelContext and updates the local assets list.
    func addAsset(for user: UserEntity, context: ModelContext) throws {
        guard let coin = selectedCoin,
              let amount = Double(inputAmount), amount > 0 else { return }
        
        if let existingAsset = assets.first(where: { $0.coin.id == coin.id }) {
            existingAsset.amount += amount
            try context.save()
        } else {
            let newAsset = UserAsset(coin: coin, amount: amount, user: user)
            context.insert(newAsset)
            try context.save()
            assets.append(newAsset)
        }
        showAddSheet = false
        selectedCoin = nil
        formMode = nil
    }
    
    /// Saves the current asset state for the specified user in the given ModelContext.
    func saveAsset(context: ModelContext) throws {
        guard let user = currentUser else { return }
        guard let coin = selectedCoin,
              let amount = Double(inputAmount), amount > 0 else { return }

        switch formMode {
        case .add:
            try addAsset(for: user, context: context)
        case .edit(let existingAsset):
            if let index = assets.firstIndex(where: { $0.id == existingAsset.id }) {
                assets[index].amount = amount
                try context.save()
            }
        case .none:
            return
        }

        showAddSheet = false
        selectedCoin = nil
        formMode = nil
    }
    
    /// Removes an asset with the specified id from local list and ModelContext.
    func removeAsset(withId id: UUID, context: ModelContext) throws {
        if let index = assets.firstIndex(where: { $0.id == id }) {
            let asset = assets[index]
            context.delete(asset)
            try context.save()
            assets.remove(at: index)
        }
    }
    
    /// Clears all assets associated with the specified user from ModelContext and local list.
    func clearAssets(for user: UserEntity, context: ModelContext) throws {
        let allAssets = try context.fetch(FetchDescriptor<UserAsset>())
        let userAssets = allAssets.filter { $0.user?.id == user.id }
        for asset in userAssets {
            context.delete(asset)
        }
        try context.save()
        assets.removeAll()
    }
    
    // MARK: - Computed total value
    var totalValueUSD: Double {
        assets.reduce(0) { $0 + $1.coin.currentPrice * $1.amount }
    }
    
    func selectCoin(_ coin: Coin) {
        selectedCoin = coin
        inputAmount = ""
        formMode = .add
        showAddSheet = true
    }
    
    func editAsset(_ asset: UserAsset) {
        selectedCoin = asset.coin
        inputAmount = String(asset.amount)
        formMode = .edit(asset)
        showAddSheet = true
    }
}

extension AssetsViewModel{
    func refreshAssetPrices(context: ModelContext) async {
            guard !assets.isEmpty else { return }

            do {
                let ids = assets.map { $0.coinID }
                let prices = try await repository.getSimplePrices(for: ids)

                for asset in assets {
                    if let newPrice = prices[asset.coinID] {
                        asset.coinPrice = newPrice
                    }
                }

                try context.save()
            } catch {
                print("❌ Failed to update prices: \(error)")
            }
        }
}
