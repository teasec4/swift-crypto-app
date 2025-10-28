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
    @ObservedObject var assetsViewModel: AssetsViewModel
    
    // creating a state for form
    @StateObject private var formState = AssetFormState()
    
    // open FullScreenAddAssetsView
    @State  var isOpenSheet: Bool = false
    
    // context to save data
    @Environment(\.modelContext) private var context
    
    // delete alert
    @State private var showDeleteAlert = false
    @State private var assetToDelete: UserAsset?
    
    var body: some View{
        VStack(alignment:.leading, spacing: 16){
            // Header
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
                                formState.startEdit(asset: asset)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.yellow)
                        }
                    
                        .swipeActions(edge: .leading){
                            // add
                            Button{
                                formState.startAdd(coin: asset.coin)
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
            // Open full screen cover to adding asset
            ToolbarItem(placement:.primaryAction){
                Button{
                    isOpenSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            
            // manual fetyching price
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await assetsViewModel.refreshAssetPrices(
                            context: context
                        )
                    }
                } label: {
                    Label("Refresh Prices", systemImage: "arrow.clockwise")
//                        .symbolEffect(.rotate.clockwise.byLayer, options: .repeat(.continuous))
                }
                
            }
        }
        
        // full screencover sheet (better to change coinListView for new VM for search)
            .fullScreenCover(isPresented:$isOpenSheet){
                FullScreenCoverAddAssetsView(coinListViewModel:coinListViewModel, assetsViewModel: assetsViewModel, formState: formState)
            }
        
        // open the form this currnet taped coin
        .sheet(isPresented: $formState.showAddSheet) {
            if let coin = formState.selectedCoin {
                AddCoinFormView(
                    coin: coin,
                    assetsViewModel: assetsViewModel,
                    formState: formState
                )
                .presentationDetents([.fraction(0.5)])
                .presentationDragIndicator(.visible)
            }
        }
        
        
        // load currentUser asset and updating price
        .onAppear {
            if let _ = assetsViewModel.currentUser {
                assetsViewModel.loadAssets(context: context)
                Task {
                    await assetsViewModel.refreshAssetPrices(context: context)
                }
            }
        }
    }
}
