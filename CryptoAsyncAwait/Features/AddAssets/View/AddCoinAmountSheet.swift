//
//  AddCoinAmountSheet.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/24/25.
//

import SwiftUI

struct AddCoinAmountSheet: View {
    @ObservedObject var assetsViewModel: AssetsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        if let coin = assetsViewModel.selectedCoin {
            VStack(spacing: 24) {
                AddCoinFormView(coin: coin, assetsViewModel: assetsViewModel, dismiss: dismiss)
                    .environment(\.modelContext, context)
                    .environmentObject(authVM)
            }
            
            .presentationDetents([.fraction(0.5)])
            .presentationDragIndicator(.visible)
        } else {
            Text("Please try again")
        }
    }
}


