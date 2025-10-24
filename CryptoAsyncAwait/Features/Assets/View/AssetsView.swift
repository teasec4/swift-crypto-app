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
                    Text("$456,80")
                        .font(.headline)
                    Text("USD")
                        .foregroundStyle(.secondary)
                }
                HStack{
                    Text("Todays PnL")
                    Text("+$5,81 (1,49%)")
                        .foregroundColor(.green)
                }
                HStack(spacing: 10){
                    
                    ForEach(0..<4) { _ in
                            VStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .foregroundColor(.blue)
                                    Image(systemName: "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90")
                                        .foregroundStyle(.white)
                                }
                                .frame(width: 50, height: 50)
                                
                                Text("Add Funds")
                            }
                        }
                   
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
                
            }
            List {
                ForEach(assetsViewModel.assets) { asset in
                        UserAssetRowView(asset: asset)
                    }
            }
            .listStyle(.plain)
        }
        .padding()
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
