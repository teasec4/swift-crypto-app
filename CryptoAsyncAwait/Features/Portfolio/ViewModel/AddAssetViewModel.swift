//
//  AddAssetViewModel.swift
//  CryptoAsyncAwait
//
//  Created by AI
//

import Foundation
import Combine
import SwiftData

/// ViewModel для формы добавления/редактирования ассета
@MainActor
final class AddAssetViewModel: ObservableObject {
    enum FormMode {
        case add(Coin)
        case edit(UserAsset)
        case idle
    }
    
    @Published var mode: FormMode = .idle
    @Published var inputAmount: String = ""
    @Published var showSheet = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let validator: AssetValidatorProtocol
    private weak var portfolioViewModel: PortfolioViewModel?
    
    init(
        validator: AssetValidatorProtocol = AssetValidator(),
        portfolioViewModel: PortfolioViewModel? = nil
    ) {
        self.validator = validator
        self.portfolioViewModel = portfolioViewModel
    }
    
    func setPortfolioViewModel(_ viewModel: PortfolioViewModel) {
        self.portfolioViewModel = viewModel
    }
    
    // MARK: - Actions
    
    func startAdd(coin: Coin) {
        mode = .add(coin)
        inputAmount = ""
        showSheet = true
        errorMessage = nil
    }
    
    func startEdit(asset: UserAsset) {
        mode = .edit(asset)
        inputAmount = String(asset.amount)
        showSheet = true
        errorMessage = nil
    }
    
    func reset() {
        mode = .idle
        inputAmount = ""
        showSheet = false
        errorMessage = nil
    }
    
    func submit(context: ModelContext) async {
        guard let amount = Double(inputAmount), validator.validateAmount(amount) else {
            errorMessage = "Please enter a valid amount"
            return
        }
        
        // ✅ Явная проверка что portfolioViewModel всё ещё существует
        guard let portfolioViewModel = portfolioViewModel else {
            errorMessage = "Portfolio is not available. Please try again."
            print("❌ AddAssetViewModel: portfolioViewModel is nil")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            switch mode {
            case .add(let coin):
                print("💾 Saving: \(coin.name) x\(amount)")
                try portfolioViewModel.addAsset(coin: coin, amount: amount, context: context)
                print("✅ Save successful!")
                reset()
            case .edit(let asset):
                print("📝 Updating: \(asset.coinName) to \(amount)")
                try portfolioViewModel.updateAsset(asset, newAmount: amount, context: context)
                print("✅ Update successful!")
                reset()
            case .idle:
                break
            }
        } catch {
            print("❌ Error: \(error)")
            errorMessage = "Failed to save asset: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Computed Properties
    
    var selectedCoin: Coin? {
        switch mode {
        case .add(let coin):
            return coin
        case .edit(let asset):
            return asset.coin
        case .idle:
            return nil
        }
    }
    
    var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }
    
    var formTitle: String {
        isEditMode ? "Edit Asset" : "Add Asset"
    }
    
    var submitButtonTitle: String {
        isEditMode ? "Save Changes" : "Add to Assets"
    }
    
    var totalValue: Double {
        guard let amount = Double(inputAmount), let coin = selectedCoin else { return 0 }
        return amount * coin.currentPrice
    }
}
