//
//  CoinAPI.swift
//  CryptoAsyncAwait
//
//  Created by Max Kovalev on 10/9/25.
//
import Foundation

final class CoinAPI: CoinDataFetchingService, GlobalMarketDataFetchingService, ChartDataFetchingService, SimplePriceFetchingService {
    private let network: NetworkServiceProtocol
    private let baseURL = "https://api.coingecko.com/api/v3/"
    
    init(network: NetworkServiceProtocol = NetworkService()) {
        self.network = network
    }
    
    // MARK: - CoinDataFetchingService
    func fetchCoins(page: Int, limit: Int) async throws -> [Coin] {
        let url = URL(string: "\(baseURL)/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=\(limit)&page=\(page)&sparkline=false")!
        return try await network.request(url)
    }
    
    // MARK: - GlobalMarketDataFetchingService
    func fetchGlobalData() async throws -> GlobalMarketData {
        let url = URL(string: "\(baseURL)/global")!
        let response: GlobalResponse = try await network.request(url)
        return response.data
    }
    
    // MARK: - ChartDataFetchingService
    func fetchChartData(for coinID: String, days: Int = 30) async throws -> [PricePoint] {
        let url = URL(string: "\(baseURL)/coins/\(coinID)/market_chart?vs_currency=usd&days=\(days)")!
        let json = try await network.requestRawJSON(url)
        
        guard let prices = json["prices"] as? [[Any]] else {
            throw URLError(.cannotParseResponse)
        }
        
        return prices.compactMap { entry in
            if let ts = entry[0] as? Double, let price = entry[1] as? Double {
                return PricePoint(date: Date(timeIntervalSince1970: ts / 1000), price: price)
            }
            return nil
        }
    }
    
    // MARK: - SimplePriceFetchingService
    func fetchSimplePrices(for coinIDs: [String]) async throws -> [String: Double] {
        let ids = coinIDs.joined(separator: ",")
        guard let url = URL(string: "\(baseURL)/simple/price?ids=\(ids)&vs_currencies=usd") else {
            throw URLError(.badURL)
        }

        let response: [String: [String: Double]] = try await network.request(url)
        
        return response.mapValues { $0["usd"] ?? 0.0 }
    }
}
