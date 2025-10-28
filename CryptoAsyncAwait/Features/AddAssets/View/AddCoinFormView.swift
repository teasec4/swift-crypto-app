//
//  AddCoinFormView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/24/25.
//

import SwiftUI

struct AddCoinFormView: View {
    // context for saving id DB for current User
    @Environment(\.modelContext) private var context
    
    @Environment(\.dismiss) private var dismiss
    
    // dependencies
    let coin: Coin
    @ObservedObject var assetsViewModel: AssetsViewModel
    @ObservedObject var formState: AssetFormState
    
    // succes toast
    @State private var showToast = false
    
    // computed helper for button view
    private var amountValue: Double {
        Double(formState.inputAmount) ?? 0
    }
    
    private var total: Double {
        amountValue * coin.currentPrice
    }
    
    var body: some View {
        ZStack{
            VStack{
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
                    
                    VStack{
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
                    TextField("Enter amount to add", text: $formState.inputAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                        .font(.title)
                    
                }
                
                // save button
                Button {
                    guard amountValue > 0 else { return }
                    // unwrap current user
                    guard let currentUser = assetsViewModel.currentUser else { return }
                    
                    switch formState.mode{
                    case .add:
                        try? assetsViewModel.addAsset(
                            coin: coin,
                            amount: amountValue,
                            context: context
                        )
                    case .edit(let existing):
                        try? assetsViewModel.updateAsset(
                            existing,
                            newAmount: amountValue,
                            context: context
                        )
                    case .none:
                        break
                        
                    }
                    
                    showToastFeedback()
                    
                    // close the form
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        formState.reset()
                        dismiss()
                        
                    }
                } label: {
                    // trying make button looks better :)
                    HStack {
                        Text(formState.modeIsEdit ? "Save Changes" : "Add to Asset")
                            .foregroundStyle(.black)
                        Spacer()
                        HStack {
                            AsyncImage(url: coin.imageUrl) { image in
                                image.resizable().scaledToFit().frame(width: 20, height: 20)
                            } placeholder: {
                                Circle().fill(Color(.systemGray5)).frame(width: 20, height: 20)
                            }
                            Text(formState.inputAmount)
                                .foregroundStyle(.black)
                        }
                        Spacer()
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.green)
                                .frame(width: 20, height: 20)
                            Text("≈ \(total.toCurrency())")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        .white
                    )
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .disabled(Double(formState.inputAmount) == nil || Double(formState.inputAmount)! <= 0)
            }
            // Toast
            if showToast {
                VStack {
                    Spacer()
                    Label("Added \(formState.inputAmount) \(coin.symbol.uppercased())", systemImage: "checkmark.circle.fill")
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

private extension AssetFormState {
    var modeIsEdit: Bool {
        if case .edit = mode { return true } else { return false }
    }
}
