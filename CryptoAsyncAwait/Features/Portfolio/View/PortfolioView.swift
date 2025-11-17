//
//  PortfolioView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев
//

import SwiftUI
import SwiftData

struct PortfolioView: View {
    @ObservedObject var portfolioViewModel: PortfolioViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    // context to save data
    @Environment(\.modelContext) private var context
    
    // delete alert
    @State private var showDeleteAlert = false
    @State private var assetToDelete: UserAsset?
    
    // edit sheet
    @StateObject private var editFormViewModel = AddAssetViewModel()
    @State private var showEditSheet = false
    
    // refresh error handling
    @State private var refreshError: String?
    @State private var showRefreshError = false
    
    var body: some View{
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            NavigationStack {
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
                        Text(portfolioViewModel.totalValueUSD.toCurrency())
                            .font(.headline)
                        Text("USD")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                
                List {
                    ForEach(portfolioViewModel.assets) { asset in
                        PortfolioAssetRowView(asset: asset)
                            .swipeActions(edge: .trailing) {
                                Button {
                                    assetToDelete = asset
                                    showDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                                
                                Button {
                                    editFormViewModel.startEdit(asset: asset)
                                    showEditSheet = true
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.yellow)
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    editFormViewModel.startAdd(coin: asset.coin)
                                    showEditSheet = true
                                } label: {
                                    Label("Add More", systemImage: "plus")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .alert("Deleting asset", isPresented: $showDeleteAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        if let asset = assetToDelete {
                            try? portfolioViewModel.removeAsset(withId: asset.id, context: context)
                        }
                    }
                } message: {
                    if let name = assetToDelete?.coin.name {
                        Text("Are you sure you want to delete «\(name)»?")
                    } else {
                        Text("Are you sure you want to delete this asset?")
                    }
                }
                .alert("Failed to Update Prices", isPresented: $showRefreshError) {
                    Button("Retry") {
                        Task {
                            await refreshAssetPrices()
                        }
                    }
                    Button("OK", role: .cancel) { }
                } message: {
                    if let error = refreshError {
                        Text(error)
                    } else {
                        Text("Unable to refresh prices at this time")
                    }
                }
                .refreshable {
                    await refreshAssetPrices()
                }
            }
            
            .navigationTitle("Portfolio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await refreshAssetPrices()
                        }
                    } label: {
                        Label("Refresh Prices", systemImage: "arrow.clockwise")
                    }
                }
            }
            
            .sheet(isPresented: $showEditSheet) {
                if let coin = editFormViewModel.selectedCoin {
                    AddAssetFormView(
                        coin: coin,
                        viewModel: editFormViewModel
                    )
                    .environmentObject(portfolioViewModel)
                    .presentationDetents([.fraction(0.5)])
                    .presentationDragIndicator(.visible)
                }
            }
            .onAppear {
                print("📱 PortfolioView appeared, user: \(portfolioViewModel.currentUser?.email ?? "nil")")
                editFormViewModel.setPortfolioViewModel(portfolioViewModel)
                loadAssetsData()
            }
            .onChange(of: portfolioViewModel.currentUser) { newUser in
                if newUser != nil {
                    loadAssetsData()
                }
            }
            }
        }
    }
    
    private func loadAssetsData() {
        portfolioViewModel.loadAssets(context: context)
        Task {
            await portfolioViewModel.refreshAssetPrices(context: context)
        }
    }
    
    private func refreshAssetPrices() async {
        do {
            try await portfolioViewModel.forceRefreshAssetPrices(context: context)
        } catch {
            refreshError = error.localizedDescription
            showRefreshError = true
        }
    }
}
