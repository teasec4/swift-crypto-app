//
//  PortfolioView.swift
//  CryptoAsyncAwait
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
    @EnvironmentObject var editFormViewModel: AddAssetViewModel
    @State private var showEditSheet = false
    
    // refresh error handling
    @State private var refreshError: String?
    @State private var showRefreshError = false
    @State private var isRefreshing = false
    @State private var showRefreshSuccess = false
    
    var body: some View{
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            NavigationStack {
                VStack(spacing: 0) {
                    // Header with stats
                    headerCard
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                    
                    // Content
                    if portfolioViewModel.assets.isEmpty {
                        emptyPortfolioView
                    } else {
                        assetsList
                    }
                    
                    Spacer()
                }
                .navigationTitle("Portfolio")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            Task {
                                isRefreshing = true
                                await refreshAssetPrices()
                                isRefreshing = false
                            }
                        }) {
                            if isRefreshing {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }
                        .disabled(isRefreshing)
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
                loadAssetsDataAsync()
            }
            .onChange(of: portfolioViewModel.currentUser) { newUser in
                if newUser != nil {
                    loadAssetsDataAsync()
                }
            }
            
            // Success Toast
            if showRefreshSuccess {
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Prices updated")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.green.opacity(0.8))
                    .cornerRadius(8)
                    .padding()
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: showRefreshSuccess)
            }
        }
    }
    
    // MARK: - Header Card
    @ViewBuilder
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Assets")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("Portfolio Balance")
                        .font(.system(size: 14, weight: .semibold))
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "eye.slash")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(alignment: .bottom, spacing: 6) {
                Text(portfolioViewModel.totalValueUSD.toCurrency())
                    .font(.system(size: 32, weight: .bold))
                    .lineLimit(1)
                
                Text("USD")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 2)
            }
            
            // Stats row
            HStack(spacing: 0) {
                statItem(
                    label: "Assets",
                    value: "\(portfolioViewModel.assets.count)"
                )
                
                Divider()
                    .frame(height: 24)
                
                statItem(
                    label: "24h Change",
                    value: "—"  // TODO: Calculate 24h change
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.12),
                    Color.blue.opacity(0.06)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func statItem(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 13, weight: .semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
    }
    
    // MARK: - Empty State
    @ViewBuilder
    private var emptyPortfolioView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "briefcase.fill")
                .font(.system(size: 56, weight: .light))
                .foregroundColor(.blue.opacity(0.4))
            
            VStack(spacing: 8) {
                Text("No Assets Yet")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Start building your portfolio by adding coins from the Markets tab")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.backgroundColor)
    }
    
    // MARK: - Assets List
    @ViewBuilder
    private var assetsList: some View {
        List {
            ForEach(portfolioViewModel.assets) { asset in
                PortfolioAssetRowView(
                    asset: asset,
                    totalPortfolioValue: portfolioViewModel.totalValueUSD
                )
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        assetToDelete = asset
                        showDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        editFormViewModel.startEdit(asset: asset)
                        showEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
                .swipeActions(edge: .leading) {
                    Button {
                        editFormViewModel.startAdd(coin: asset.coin)
                        showEditSheet = true
                    } label: {
                        Label("Add More", systemImage: "plus.circle")
                    }
                    .tint(.green)
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable {
            await refreshAssetPrices()
        }
        .alert("Delete Asset", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let asset = assetToDelete {
                    try? portfolioViewModel.removeAsset(withId: asset.id, context: context)
                }
            }
        } message: {
            if let name = assetToDelete?.coin.name {
                Text("Are you sure you want to delete «\(name)»? This action cannot be undone.")
            } else {
                Text("Are you sure you want to delete this asset?")
            }
        }
        .alert("Failed to Update Prices", isPresented: $showRefreshError) {
            Button("Retry") {
                Task {
                    isRefreshing = true
                    await refreshAssetPrices()
                    isRefreshing = false
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
    }
    
    // MARK: - Private Methods
    
    private func loadAssetsDataAsync() {
        Task {
            portfolioViewModel.loadAssets(context: context)
            await portfolioViewModel.refreshAssetPrices(context: context)
        }
    }
    
    private func refreshAssetPrices() async {
        do {
            try await portfolioViewModel.forceRefreshAssetPrices(context: context)
            withAnimation {
                showRefreshSuccess = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showRefreshSuccess = false
                }
            }
        } catch {
            refreshError = error.localizedDescription
            showRefreshError = true
        }
    }
}
