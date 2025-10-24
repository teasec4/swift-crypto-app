//
//  AddCoinAmountSheet.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/24/25.
//

import SwiftUI

struct AddCoinAmountSheet: View {
    @ObservedObject var assetsViewModel: AssetsViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack{
            if let coin = assetsViewModel.selectedCoin{
                Text("Add \(coin.name)")
                    .font(.title2)
                    .fontWeight(.semibold)
                TextField("Enter amount", text: $assetsViewModel.inputAmount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                Button {
                    assetsViewModel.addAsset()
                    dismiss()
                } label: {
                    Text("Add to Portfolio")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }

        }
    }
}


