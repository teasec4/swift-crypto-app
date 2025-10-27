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
    
    @State private var showDeleteAlert = false
    @State private var assetToDelete: UserAsset?
    
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
                        .swipeActions(edge: .trailing){
                            // delete
                            Button{
                                assetToDelete = asset
                                showDeleteAlert = true
                                
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                            
                            // update
                            Button{
                                assetsViewModel.editAsset(asset)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.yellow)
                        }
                    
                        .swipeActions(edge: .leading){
                            // add
                            Button{
                                assetsViewModel.selectCoin(asset.coin)
                            } label: {
                                Label("Add", systemImage: "plus")
                            }
                        }
                }
            }
            .listStyle(.plain)
            .alert("Delete your asset?", isPresented: $showDeleteAlert){
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let asset = assetToDelete {
                        assetsViewModel.removeAsset(withId: asset.id)
                    }
                }
            } message: {
                if let name = assetToDelete?.coin.name {
                                Text("Are you sure you want to delete «\(name)»?")
                            } else {
                                Text("Are you sure you want to delete this asset?")
                            }
            }
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
        
        .sheet(isPresented: $assetsViewModel.showAddSheet){
            AddCoinAmountSheet(assetsViewModel: assetsViewModel)
        }
    }
}
