//
//  GlobalMarketDataTest.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/21/25.
//
import XCTest
@testable import CryptoAsyncAwait

final class GlobalMarketDataTest:XCTestCase{
    func test_GlobalMarketData_decodesSuccessfully() throws {
        // given json like a real CoinGecko API
        let json = """
                {
                    "data": {
                        "total_market_cap": {
                            "usd": 1234567890.12,
                            "btc": 45678.9
                        },
                        "total_volume": {
                            "usd": 987654321.0,
                            "eth": 12345.67
                        },
                        "market_cap_change_percentage_24h_usd": -2.56
                    }
                }
                """
        
        // when
        let data = Data(json.utf8)
        let decoded = try JSONDecoder().decode(GlobalResponse.self, from: data)
        
        // then
        XCTAssertEqual(decoded.data.totalMarketCap?["usd"], 1234567890.12)
        XCTAssertEqual(decoded.data.totalVolume?["eth"], 12345.67)
        XCTAssertEqual(decoded.data.marketCapChangePercentage24hUsd, -2.56)
    }
    
    func test_GlobalMarketData_handlesMissingKeys() throws{
        // given json miss total_volume
        let json = """
                {
                    "data": {
                        "total_market_cap": {
                            "usd": 1234567890.12,
                            "btc": 45678.9
                        },
                        "market_cap_change_percentage_24h_usd": -2.56
                    }
                }
                """
        
        // when
        let data = Data(json.utf8)
        
        // then
        let decoded = try JSONDecoder().decode(GlobalResponse.self, from: data)
        
        XCTAssertEqual(decoded.data.totalMarketCap?["usd"], 1234567890.12)
        XCTAssertNil(decoded.data.totalVolume)
    }
}
