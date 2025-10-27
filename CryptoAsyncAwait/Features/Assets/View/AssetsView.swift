//
//  AssetsView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/24/25.
//
import SwiftUI
import SwiftData

struct AssetsView: View{
    @ObservedObject var coinListViewModel: CoinListViewModel
    @State private var isOpenSheet: Bool = false
    @ObservedObject var assetsViewModel: AssetsViewModel
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var authVM: AuthViewModel
    
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
//                HStack{
//                    Text("Todays PnL")
//                    Text("+$5,81 (1,49%)")
//                        .foregroundColor(.green)
//                }
                
            }
            .padding()
            .onAppear {
                if let user = authVM.user {
                    assetsViewModel.currentUser = user
                    assetsViewModel.loadAssets(for: user, context: context)
                }
            }
            
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
            .alert("Deleting asset", isPresented: $showDeleteAlert){
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let asset = assetToDelete {
                           try? assetsViewModel.removeAsset(withId: asset.id, context: context)
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
            
            ToolbarItem(placement: .navigationBarTrailing) {
                   Button {
                       Task {
                           await assetsViewModel.refreshAssetPrices(
                               context: context
                           )
                       }
                   } label: {
                       Label("Refresh Prices", systemImage: "arrow.clockwise")
                   }
               }
        }
        .fullScreenCover(isPresented:$isOpenSheet){
            FullScreenCoverAddAssetsView(coinListViewModel:coinListViewModel, assetsViewModel: assetsViewModel)
        }
        
        .sheet(isPresented: $assetsViewModel.showAddSheet){
            AddCoinAmountSheet(assetsViewModel: assetsViewModel)
        }
        .onAppear{
            Task{
                await assetsViewModel.refreshAssetPrices(context: context)
            }
        }
    }
}
