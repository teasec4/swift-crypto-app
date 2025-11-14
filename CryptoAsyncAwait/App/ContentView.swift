

import SwiftUI

struct ContentView: View {
    // Main page ViewModels
    @StateObject private var pageViewModel = CoinsPageViewModel()
    @StateObject private var globalMarketViewModel = GlobalMarketViewModel()
    @StateObject private var coinListViewModel = CoinListViewModel()
    @StateObject private var assetsViewModel = AssetsViewModel()
    @StateObject private var addAssetViewModel = AddAssetViewModel()
    
    // setup user
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.modelContext) private var context
    
    // for custom tab bar
    @State private var selected = 0
       
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                NavigationStack {
                    CoinsPage()
                        .environmentObject(pageViewModel)
                        .environmentObject(globalMarketViewModel)
                        .environmentObject(coinListViewModel)
                        .environmentObject(addAssetViewModel)
                        .environmentObject(assetsViewModel)
                        .navigationTitle("Coins")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .opacity(selected == 0 ? 1 : 0)
                .allowsHitTesting(selected == 0)
                .animation(nil, value: selected)
                
                NavigationStack {
                    AssetsView(coinListViewModel: coinListViewModel, assetsViewModel: assetsViewModel)
                        .navigationTitle("Assets")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .environment(\.modelContext, context)
                .opacity(selected == 1 ? 1 : 0)
                .animation(nil, value: selected)
                
                NavigationStack {
                    ProfileView()
                        .navigationTitle("Profile")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .environment(\.modelContext, context)
                .opacity(selected == 2 ? 1 : 0)
                .animation(nil, value: selected)
            }
            .transition(.identity)
            .animation(.none, value: selected)

            CustomTabBar(selected: $selected)
        }
        .background(Color.black.ignoresSafeArea())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: authVM.user) { newUser in
            print("👤 User changed: \(newUser?.email ?? "nil")")
            assetsViewModel.currentUser = newUser
            if let user = newUser {
                print("📲 Loading assets for: \(user.email)")
                assetsViewModel.loadAssets(context: context)
                addAssetViewModel.setAssetsViewModel(assetsViewModel)
            }
        }
        .onAppear {
            print("🚀 App appeared")
            if let user = authVM.user {
                print("👤 Current user: \(user.email)")
                assetsViewModel.currentUser = user
                assetsViewModel.loadAssets(context: context)
                addAssetViewModel.setAssetsViewModel(assetsViewModel)
            } else {
                print("⚠️ No user on app appear")
            }
            Task {
                async let globalData = globalMarketViewModel.loadGlobalData()
                async let coinsData = coinListViewModel.loadCoins()
                _ = await (globalData, coinsData)
            }
        }
    }
}



