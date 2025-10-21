//
//  PricePointTest.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/21/25.
//
import XCTest
@testable import CryptoAsyncAwait

final class PricePointTest: XCTestCase{
    func test_price_point_decodesFromJSON() throws{
        let json = """
        {
            "id": "3F2504E0-4F89-11D3-9A0C-0305E82C3301",
            "date": "2024-10-21T12:00:00Z",
            "price": 1.1
        }
        """
        
        let data = Data(json.utf8)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let decoded = try decoder.decode(PricePoint.self, from: data)
        
        XCTAssertEqual(decoded.price, 1.1)
        XCTAssertNotNil(decoded.date)
    }
}
