//
//  CoinListViewTest.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/22/25.
//
import XCTest
import SwiftUI
import ViewInspector
@testable import CryptoAsyncAwait

extension CoinListView: Inspectable{}

@MainActor
final class CoinListViewTests: XCTestCase{
    
    // MARK: Loading state
    func test_showsProgressViewWhenLoading() throws{
        // given
        let vm = CoinListViewModel()
        vm.state = .loading
        
        let view = CoinListView(coinListViewModel: vm)
        ViewHosting.host(view: view)
        
        // then
        XCTAssertNoThrow(try view.inspect().find(ViewType.ProgressView.self))
        
        ViewHosting.expel()
    }
   
    
    
}
