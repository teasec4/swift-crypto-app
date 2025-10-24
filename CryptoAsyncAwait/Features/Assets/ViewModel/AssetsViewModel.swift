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
    
    func selectCoin(_ coin: Coin) {
        selectedCoin = coin
        inputAmount = ""
        showAddSheet = true
    }
    
    func addAsset() {
        guard let coin = selectedCoin,
              let amount = Double(inputAmount), amount > 0 else { return }
        
       
        if let index = assets.firstIndex(where: { $0.coin.id == coin.id }) {
            assets[index].amount += amount
        } else {
            assets.append(UserAsset(coin: coin, amount: amount))
        }
        showAddSheet = false
        selectedCoin = nil
    }
    
    func removeAsset(at offsets: IndexSet) {
        assets.remove(atOffsets: offsets)
    }
}
