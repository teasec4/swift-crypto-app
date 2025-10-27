//
//  AssetsViewModel.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/24/25.
//
import SwiftUI
import Combine

@MainActor
final class AssetsViewModel: ObservableObject{
    @Published private(set) var assets: [UserAsset] = []
    @Published var selectedCoin: Coin? = nil
    @Published var inputAmount: String = ""
    @Published var showAddSheet = false
    @Published var formMode: AssetFormMode? = nil
    
    enum AssetFormMode {
        case add
        case edit(UserAsset)
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
    
    func saveAsset() {
        guard let coin = selectedCoin,
              let amount = Double(inputAmount), amount > 0 else { return }
        
       
        switch formMode {
            case .add:
                if let index = assets.firstIndex(where: { $0.coin.id == coin.id }) {
                    assets[index].amount += amount
                } else {
                    assets.append(UserAsset(coin: coin, amount: amount))
                }
            case .edit(let existingAsset):
                if let index = assets.firstIndex(where: { $0.id == existingAsset.id }) {
                    assets[index].amount = amount
                }
            case .none:
                return
            }
        
        showAddSheet = false
        selectedCoin = nil
        formMode = nil
    }
    
    func removeAsset(withId id: UUID) {
            assets.removeAll { $0.id == id }
        }
    
    // MARK: - Computed total value
        var totalValueUSD: Double {
            assets.reduce(0) { $0 + $1.coin.currentPrice * $1.amount }
        }
}
