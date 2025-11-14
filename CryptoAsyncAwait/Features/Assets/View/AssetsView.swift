//
//  AssetsView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/24/25.
//
import SwiftUI
import SwiftData

struct AssetsView: View {
    @ObservedObject var coinListViewModel: CoinListViewModel
    @ObservedObject var assetsViewModel: AssetsViewModel
    
    // creating a state for form
    @StateObject private var formViewModel = AddAssetViewModel()
    
    // open AddAssetModalView
    @State private var isOpenSheet: Bool = false
    
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
                            Button {
                                formViewModel.startEdit(asset: asset)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.yellow)
                        }
                    
                        .swipeActions(edge: .leading) {
                            // add
                            Button {
                                formViewModel.startAdd(coin: asset.coin)
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
        
        
        .toolbar {
            // Open full screen cover to adding asset
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isOpenSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            
            // manual fetching price
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await assetsViewModel.forceRefreshAssetPrices(
                            context: context
                        )
                    }
                } label: {
                    Label("Refresh Prices", systemImage: "arrow.clockwise")
                }
            }
        }
        
        // full screen cover sheet for adding asset
        .fullScreenCover(isPresented: $isOpenSheet) {
            AddAssetModalView(
                coinListViewModel: coinListViewModel,
                viewModel: formViewModel
            )
            .environmentObject(assetsViewModel)
        }
        
        // open the form for selected coin
        .sheet(isPresented: $formViewModel.showSheet) {
            if let coin = formViewModel.selectedCoin {
                AddAssetFormView(
                    coin: coin,
                    viewModel: formViewModel
                )
                .environmentObject(assetsViewModel)
                .presentationDetents([.fraction(0.5)])
                .presentationDragIndicator(.visible)
            }
        }
        
        // load currentUser assets and update prices
        .onAppear {
            // ✅ currentUser уже установлен из ContentView
            print("📱 AssetsView appeared, user: \(assetsViewModel.currentUser?.email ?? "nil")")
            formViewModel.setAssetsViewModel(assetsViewModel)
            loadAssetsData()
        }
        .onChange(of: assetsViewModel.currentUser) { newUser in
            // ✅ Если пользователь изменился, перезагружаем ассеты
            if newUser != nil {
                loadAssetsData()
            }
        }
    }
    
    private func loadAssetsData() {
        assetsViewModel.loadAssets(context: context)
        Task {
            await assetsViewModel.refreshAssetPrices(context: context)
        }
    }
}
