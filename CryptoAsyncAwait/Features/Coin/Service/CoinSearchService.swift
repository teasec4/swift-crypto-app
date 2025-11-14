//
//  CoinSearchService.swift
//  CryptoAsyncAwait
//
//  Created by AI
//

import Foundation

/// Protocol для поиска и фильтрации монет
protocol CoinSearchServiceProtocol {
    func search(_ coins: [Coin], by query: String) -> [Coin]
    func filterByScope(_ coins: [Coin], scope: CoinListViewModel.SearchScope) -> [Coin]
}

final class CoinSearchService: CoinSearchServiceProtocol {
    
    func search(_ coins: [Coin], by query: String) -> [Coin] {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return coins }
        
        return coins.filter { coin in
            fuzzyMatch(coin.name.lowercased(), query)
            || fuzzyMatch(coin.symbol.lowercased(), query)
        }
    }
    
    func filterByScope(_ coins: [Coin], scope: CoinListViewModel.SearchScope) -> [Coin] {
        switch scope {
        case .top10:
            return coins
                .sorted(by: { ($0.marketCapRank ?? 0) < ($1.marketCapRank ?? 0) })
                .prefix(10)
                .map { $0 }
        case .defi:
            return coins.filter { $0.name.localizedCaseInsensitiveContains("defi") }
        case .ai:
            return coins.filter {
                $0.name.range(of: #"\bAI\b"#, options: [.regularExpression, .caseInsensitive]) != nil
            }
        case .all:
            return coins
        }
    }
    
    // MARK: - Private
    
    private func fuzzyMatch(_ text: String, _ pattern: String) -> Bool {
        if text.contains(pattern) { return true }
        
        let normalizedText = text.replacingOccurrences(of: "[^a-z0-9]", with: "", options: .regularExpression)
        let normalizedPattern = pattern.replacingOccurrences(of: "[^a-z0-9]", with: "", options: .regularExpression)
        
        if normalizedText.hasPrefix(normalizedPattern) { return true }
        
        var tIndex = normalizedText.startIndex
        for ch in normalizedPattern {
            if let found = normalizedText[tIndex...].firstIndex(of: ch) {
                tIndex = normalizedText.index(after: found)
            } else {
                return false
            }
        }
        return true
    }
}
