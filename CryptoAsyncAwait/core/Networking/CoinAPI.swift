//
//  CoinAPI.swift
//  CryptoAsyncAwait
//
//  Created by Max Kovalev on 10/9/25.
//
import Foundation

final class CoinAPI: CoinDataFetchingService, ChartDataFetchingService, SimplePriceFetchingService {
    private let network: NetworkServiceProtocol
    private let baseURL = "https://api.coingecko.com/api/v3"
    
    init(network: NetworkServiceProtocol = NetworkService()) {
        self.network = network
    }
    
    // MARK: - CoinDataFetchingService
    func fetchCoins(page: Int, limit: Int) async throws -> [Coin] {
        // ✅ Используем URLComponents для безопасного construction
        var components = URLComponents(string: baseURL + "/coins/markets")!
        components.queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "order", value: "market_cap_desc"),
            URLQueryItem(name: "per_page", value: String(limit)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sparkline", value: "false")
        ]
        
        guard let url = components.url else {
            throw CoinError.invalidURL
        }
        
        return try await network.request(url)
    }
    
    // MARK: - ChartDataFetchingService
    func fetchChartData(for coinID: String, days: Int = 30) async throws -> [PricePoint] {
        // ✅ Экранируем coinID (может содержать спецсимволы)
        let safeCoinID = coinID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? coinID
        
        var components = URLComponents(string: baseURL + "/coins/\(safeCoinID)/market_chart")!
        components.queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "days", value: String(days))
        ]
        
        guard let url = components.url else {
            throw CoinError.invalidURL
        }
        
        let json = try await network.requestRawJSON(url)
        
        guard let prices = json["prices"] as? [[Any]] else {
            throw CoinError.invalidData
        }
        
        return prices.compactMap { entry in
            // ✅ timestamp в миллисекундах с Unix epoch (от API)
            if let ts = entry[0] as? Double, let price = entry[1] as? Double {
                let date = Date(timeIntervalSince1970: ts / 1000)
                return PricePoint(date: date, price: price)
            }
            return nil
        }
    }
    
    // MARK: - SimplePriceFetchingService
    func fetchSimplePrices(for coinIDs: [String]) async throws -> [String: Double] {
        // ✅ Экранируем и валидируем IDs
        let safeIds = coinIDs
            .map { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0 }
            .joined(separator: ",")
        
        var components = URLComponents(string: baseURL + "/simple/price")!
        components.queryItems = [
            URLQueryItem(name: "ids", value: safeIds),
            URLQueryItem(name: "vs_currencies", value: "usd")
        ]
        
        guard let url = components.url else {
            throw CoinError.invalidURL
        }

        do {
            let response: [String: [String: Double]] = try await network.request(url)
            return response.mapValues { $0["usd"] ?? 0.0 }
        } catch {
            // ✅ Преобразуем любую ошибку в CoinError
            if let coinError = error as? CoinError {
                throw coinError
            } else {
                throw CoinError.serverError
            }
        }
    }
}
