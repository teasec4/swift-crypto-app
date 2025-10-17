//
//  CoinTests.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/17/25.
//
import XCTest
@testable import CryptoAsyncAwait

final class CoinTests: XCTestCase {
    func test_coin_decodesFromJSON() throws {
        let json: [String: Any] = [
            "id": "bitcoin",
            "symbol": "btc",
            "name": "Bitcoin",
            "image": "https://test.com/btc.png",
            "current_price": 50000.0,
            "market_cap_rank": 1,
            "price_change_24h": 200.0,
            "price_change_percentage_24h": 0.4
        ]
        
        let data = try JSONSerialization.data(withJSONObject: json)
        
        let decoded = try JSONDecoder().decode(Coin.self, from: data)
        
        
        XCTAssertEqual(decoded.id, "bitcoin")
        XCTAssertEqual(decoded.symbol, "btc")
        XCTAssertEqual(decoded.currentPrice, 50000.0)
        XCTAssertEqual(decoded.marketCapRank, 1)
        XCTAssertEqual(decoded.priceChange24H, 200.0)
        XCTAssertEqual(decoded.priceChangePercentage24H, 0.4)
    }
    
    func test_imageUrl_validAndInvalid(){
        let valid = Coin(id: "1", symbol: "btc", name: "Bitcoin",
                         image: "https://example.com/btc.png",
                         currentPrice: 10.0, marketCapRank: 1,
                         priceChange24H: nil, priceChangePercentage24H: nil)
        XCTAssertNotNil(valid.imageUrl)
        
        let invalid = Coin(id: "2", symbol: "eth", name: "Ethereum",
                           image: "not a url",
                           currentPrice: 20.0, marketCapRank: nil,
                           priceChange24H: nil, priceChangePercentage24H: nil)
        XCTAssertNil(invalid.imageUrl)
    }
}
