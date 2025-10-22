//
//  GlobalMarketViewModel.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/9/25.
//
import Foundation
import Combine

@MainActor
final class GlobalMarketViewModel: ObservableObject {
    @Published var state: StateView = .loading
    
    enum StateView {
        case loading
        case error(String)
        case empty
        case content(GlobalMarketData)
    }
    
    
    private let repository: GlobalRepositoryProtocol
    
    init(repository: GlobalRepositoryProtocol? = nil) {
        self.repository = repository ?? DependencyContainer.shared.globalMarketRepository
    }
    
    
    func loadGlobalData() async {
        state = .loading

        do {
            let data = try await repository.getGlobalData()
            if let cap = data.totalMarketCap, cap.isEmpty == false {
                state = .content(data)
            } else {
                state = .empty
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
