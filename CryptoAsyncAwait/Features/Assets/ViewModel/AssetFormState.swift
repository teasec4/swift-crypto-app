//
//  Untitled.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/28/25.
//
import SwiftUI
import Foundation
import Combine

final class AssetFormState: ObservableObject{
    enum Mode { case add, edit(UserAsset) }
    
    @Published var selectedCoin: Coin?
    @Published var inputAmount: String = ""
    @Published var showAddSheet = false
    @Published var mode: Mode?
    
    func startAdd(coin: Coin) {
            selectedCoin = coin
            inputAmount = ""
            mode = .add
            showAddSheet = true
        }
    
    func startEdit(asset: UserAsset) {
            selectedCoin = asset.coin
            inputAmount = String(asset.amount)
            mode = .edit(asset)
            showAddSheet = true
        }
    
    func reset() {
            selectedCoin = nil
            inputAmount = ""
            mode = nil
            showAddSheet = false
        }
}
