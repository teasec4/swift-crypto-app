//
//  AssetsView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/24/25.
//
import SwiftUI

struct AssetsView: View{
    @ObservedObject var coinListViewModel: CoinListViewModel
    @State private var isOpenSheet: Bool = false
    @ObservedObject var assetsViewModel: AssetsViewModel
    
    var body: some View{
        VStack(alignment:.leading, spacing: 16){
            VStack(alignment:.leading, spacing: 16){
                HStack{
                    Text("Total Assets")
                        .foregroundStyle(.secondary)
                        
                    Button{
                        
                    } label: {
                        Image(systemName: "eye.slash")
                            
                    }
                }
                HStack{
                    Text(assetsViewModel.totalValueUSD.toCurrency())
                        .font(.headline)
                    Text("USD")
                        .foregroundStyle(.secondary)
                }
                HStack{
                    Text("Todays PnL")
                    Text("+$5,81 (1,49%)")
                        .foregroundColor(.green)
                }
                
            }
            .padding()
            
            List {
                ForEach(assetsViewModel.assets) { asset in
                        UserAssetRowView(asset: asset)
                    }
            }
            .listStyle(.plain)
        }
        
        .toolbar{
            ToolbarItem(placement:.primaryAction){
                Button{
                    isOpenSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .fullScreenCover(isPresented:$isOpenSheet){
            FullScreenCoverAddAssetsView(coinListViewModel:coinListViewModel, assetsViewModel: assetsViewModel)
        }
    }
}
