//
//  GlobalMarketViewTest.swift
//  CryptoAsyncAwaitTests
//
//  Created by Максим Ковалев on 10/21/25.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import CryptoAsyncAwait

extension GlobalMarketHeaderView: Inspectable {}

@MainActor
final class GlobalMarketViewTests: XCTestCase {
    
    // MARK: - 1️⃣ Loading state
    func test_showsProgressViewWhenLoading() throws {
        // given
        let vm = GlobalMarketViewModel()
        vm.state = .loading
        
        let view = GlobalMarketHeaderView(viewModel: vm, disableAutoLoad: true)
        ViewHosting.host(view: view)
        
        // when / then
        XCTAssertNoThrow(try view.inspect().find(ViewType.ProgressView.self))
        
        ViewHosting.expel()
    }
    
    // MARK: - 2️⃣ Error state
    func test_showsErrorMessageWhenErrorExists() throws {
        // given
        let vm = GlobalMarketViewModel()
        vm.state = .error("Network error")
        
        let view = GlobalMarketHeaderView(viewModel: vm, disableAutoLoad: true)
        ViewHosting.host(view: view)
        
        // when
        let inspected = try view.inspect()
        let text = try inspected.find(ViewType.Text.self, where: { try $0.string().contains("Network error") })
        
        // then
        XCTAssertTrue(try text.string().contains("Network error"))
        
        ViewHosting.expel()
    }
    
    // MARK: - 3️⃣ Empty state
    func test_showsEmptyViewWhenNoData() throws {
        let vm = GlobalMarketViewModel()
        vm.state = .empty
        
        let view = GlobalMarketHeaderView(viewModel: vm, disableAutoLoad: true)
        ViewHosting.host(view: view)
        
        let inspected = try view.inspect()
        XCTAssertNoThrow(try inspected.find(textWhere: { string, _ in string.contains("No data") }))
        
        ViewHosting.expel()
    }
    
    // MARK: - 4️⃣ Content state
    func test_showsMarketDataWhenContentLoaded() throws {
        // given
        let mockData = GlobalMarketData(
            totalMarketCap: ["usd": 2_500_000_000_000],
            totalVolume: ["usd": 120_000_000_000],
            marketCapChangePercentage24hUsd: 1.72
        )
        let vm = GlobalMarketViewModel()
        vm.state = .content(mockData)
        
        let view = GlobalMarketHeaderView(viewModel: vm, disableAutoLoad: true)
        ViewHosting.host(view: view)
        
        // when
        let inspected = try view.inspect()
        
        // then
        let capText = try inspected.find(ViewType.Text.self, where: { try $0.string().contains("Global Market Cap") })
        let volText = try inspected.find(ViewType.Text.self, where: { try $0.string().contains("24h Volume") })
        
        XCTAssertNotNil(capText)
        XCTAssertNotNil(volText)
        
        ViewHosting.expel()
    }
}
