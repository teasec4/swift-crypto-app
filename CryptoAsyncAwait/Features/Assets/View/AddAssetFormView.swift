//
//  AddAssetFormView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/24/25.
//

import SwiftUI

struct AddAssetFormView: View {
    // context for saving to DB for current User
    @Environment(\.modelContext) private var context
    
    @Environment(\.dismiss) private var dismiss
    
    // dependencies
    let coin: Coin
    @ObservedObject var viewModel: AddAssetViewModel
    @EnvironmentObject var assetsViewModel: AssetsViewModel
    
    // success toast
    @State private var showToast = false
    
    // computed helper for button view
    private var amountValue: Double {
        Double(viewModel.inputAmount) ?? 0
    }
    
    var body: some View {
        ZStack {
            VStack {
                // header
                HStack(spacing: 20) {
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
                    
                    VStack {
                        Text(coin.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(coin.symbol.uppercased())
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Text(coin.currentPrice.toCurrency())
                        .font(.title)
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                }
                
                // input field
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Enter amount to add", text: $viewModel.inputAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                        .font(.title)
                }
                
                // error message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                // save button
                Button {
                    guard amountValue > 0 else { return }
                    
                    Task {
                        await viewModel.submit(context: context)
                        showToastFeedback()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            dismiss()
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.submitButtonTitle)
                            .foregroundStyle(.black)
                        Spacer()
                        HStack {
                            AsyncImage(url: coin.imageUrl) { image in
                                image.resizable().scaledToFit().frame(width: 20, height: 20)
                            } placeholder: {
                                Circle().fill(Color(.systemGray5)).frame(width: 20, height: 20)
                            }
                            Text(viewModel.inputAmount)
                                .foregroundStyle(.black)
                        }
                        Spacer()
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.green)
                                .frame(width: 20, height: 20)
                            Text("≈ \(viewModel.totalValue.toCurrency())")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .disabled(amountValue <= 0 || viewModel.isLoading)
            }
            
            // Toast
            if showToast {
                VStack {
                    Spacer()
                    Label("Added \(viewModel.inputAmount) \(coin.symbol.uppercased())", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                        .shadow(radius: 4)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 40)
                }
                .animation(.easeInOut, value: showToast)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showToast)
    }
    
    // helper for toast
    private func showToastFeedback() {
        withAnimation {
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation {
                showToast = false
            }
        }
    }
}
