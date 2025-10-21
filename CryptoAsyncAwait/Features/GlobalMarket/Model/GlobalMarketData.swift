//
//  GlobalMarket.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/9/25.
//

struct GlobalMarketData: Decodable {
    let totalMarketCap: [String: Double]?
    let totalVolume: [String: Double]?
    let marketCapChangePercentage24hUsd: Double?

    enum CodingKeys: String, CodingKey {
           case totalMarketCap = "total_market_cap"
           case totalVolume = "total_volume"
           case marketCapChangePercentage24hUsd = "market_cap_change_percentage_24h_usd"
       }
}

struct GlobalResponse: Decodable {
    let data: GlobalMarketData
}
