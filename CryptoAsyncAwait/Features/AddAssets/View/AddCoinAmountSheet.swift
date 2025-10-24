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
    
    var body: some View {
        if let coin = assetsViewModel.selectedCoin {
            VStack(spacing: 24) {
                
                // MARK: - Header
                VStack(spacing: 8) {
                    AsyncImage(url: coin.imageUrl) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .shadow(radius: 4)
                    } placeholder: {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 60, height: 60)
                    }
                    
                    Text(coin.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(coin.symbol.uppercased())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(coin.currentPrice.toCurrency())
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                }

                // MARK: - Input Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter amount to add")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 4)
                    
                    TextField("0.00", text: $assetsViewModel.inputAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    // 💰 Live total value
                    if let amount = Double(assetsViewModel.inputAmount), amount > 0 {
                        let total = amount * coin.currentPrice
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.green)
                            Text("≈ \(total.toCurrency())")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal)
                        .transition(.opacity)
                    }
                }

                // MARK: - Button
                Button {
                    assetsViewModel.addAsset()
                    dismiss()
                } label: {
                    Text("Add to Portfolio")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.3), radius: 3, x: 0, y: 2)
                }
                .padding(.horizontal)
                .disabled(Double(assetsViewModel.inputAmount) == nil || Double(assetsViewModel.inputAmount)! <= 0)
                .opacity((Double(assetsViewModel.inputAmount) ?? 0) > 0 ? 1 : 0.5)
                .animation(.easeInOut(duration: 0.2), value: assetsViewModel.inputAmount)

                Spacer()
            }
            .padding(.top, 20)
            .presentationDetents([.fraction(0.5)])
            .presentationDragIndicator(.visible)
        }
    }
}
