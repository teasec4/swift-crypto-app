//
//  CoinsPageViewModel.swift
//  CryptoAsyncAwait
//
//  Created by AI
//

import Foundation
import Combine

/// Простой ViewModel для управления модальным окном добавления ассета
@MainActor
final class CoinsPageViewModel: ObservableObject {
    @Published var showAddAssetModal = false
    
    // MARK: - Actions
    func openAddAssetModal() {
        showAddAssetModal = true
    }
    
    func closeAddAssetModal() {
        showAddAssetModal = false
    }
}
