//
//  AddCoinFormView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/24/25.
//

import SwiftUI

struct AddCoinFormView: View {
    let coin: Coin
    @ObservedObject var assetsViewModel: AssetsViewModel
    var dismiss: DismissAction
    
    @Environment(\.modelContext) private var context
    
    
    private var total: Double {
        let amount = Double(assetsViewModel.inputAmount) ?? 0.0
        return amount * coin.currentPrice
    }
    
    var body: some View {
        VStack{
            // MARK: - Header
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
            
            // MARK: - Input Field
            VStack(alignment: .leading, spacing: 8) {
                    TextField("Enter amount to add", text: $assetsViewModel.inputAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                        .font(.title)
     
            }
            
            // MARK: - Button
            Button {
                if assetsViewModel.currentUser != nil {
                        try? assetsViewModel.saveAsset(context: context)
                        dismiss()
                    }
            } label: {
                HStack {
                    if case .edit = assetsViewModel.formMode {
                        Text("Save Changes")
                            .foregroundStyle(.white)
                    } else {
                        Text("Add to Asset")
                            .foregroundStyle(.white)
                    }
                        
                    Spacer()
                    HStack {
                        AsyncImage(url: coin.imageUrl) { image in
                            image.resizable().scaledToFit().frame(width: 20, height: 20)
                        } placeholder: {
                            Circle().fill(Color(.systemGray5)).frame(width: 20, height: 20)
                        }
                        Text(assetsViewModel.inputAmount)
                            .foregroundStyle(.white)
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
                    LinearGradient(colors: [.blue.opacity(0.9), .purple.opacity(0.8)],
                                   startPoint: .leading,
                                   endPoint: .trailing)
                )
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .disabled(Double(assetsViewModel.inputAmount) == nil || Double(assetsViewModel.inputAmount)! <= 0)
            
        }
    }
}


#Preview {
    let vm = AssetsViewModel()
    // создаём тестовую монету
    let demoCoin = Coin(
        id: "bitcoin",
        symbol: "btc",
        name: "Bitcoin",
        image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
        currentPrice: 68000,
        marketCapRank: 1, priceChange24H: 1,
        priceChangePercentage24H: 2.5
    )
    vm.selectedCoin = demoCoin
    
    return AddCoinAmountSheet(assetsViewModel: vm)
}
