import SwiftUI

struct ContentView: View {
    // MARK: - ViewModels
    
    @StateObject private var portfolioViewModel = PortfolioViewModel()
    @StateObject private var marketsListViewModel = MarketsListViewModel()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var addAssetViewModel: AddAssetViewModel
    
    init() {
        let portfolioVM = PortfolioViewModel()
        _portfolioViewModel = StateObject(wrappedValue: portfolioVM)
        _marketsListViewModel = StateObject(wrappedValue: MarketsListViewModel())
        _themeManager = StateObject(wrappedValue: ThemeManager())
        _addAssetViewModel = StateObject(wrappedValue: AddAssetViewModel(portfolioViewModel: portfolioVM))
    }
    
    // MARK: - Environment
    
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.modelContext) private var context
    
    // MARK: - State
    
    @State private var selected = 0
       
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                MarketsPage()
                    .environmentObject(marketsListViewModel)
                    .environmentObject(portfolioViewModel)
                    .environmentObject(addAssetViewModel)
                    .environmentObject(themeManager)
                    .opacity(selected == 0 ? 1 : 0)
                    .allowsHitTesting(selected == 0)
                    .animation(nil, value: selected)
                
                NavigationStack {
                    PortfolioView(portfolioViewModel: portfolioViewModel)
                        .environmentObject(addAssetViewModel)
                        .environmentObject(themeManager)
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

            NavigationTabBar(selected: $selected)
        }
        .background(themeManager.backgroundColor.ignoresSafeArea())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        .environmentObject(themeManager)
        .onChange(of: authVM.user) { newUser in
            print("👤 User changed: \(newUser?.email ?? "nil")")
            portfolioViewModel.currentUser = newUser
            
            if newUser != nil {
                print("📲 Loading portfolio for: \(newUser?.email ?? "")")
                portfolioViewModel.loadAssets(context: context)
            }
        }
        .onAppear {
            print("🚀 ContentView appeared")
            
            if let user = authVM.user {
                print("👤 Current user: \(user.email)")
                portfolioViewModel.currentUser = user
                portfolioViewModel.loadAssets(context: context)
            }
            
            // Загружаем монеты для основного списка
            Task {
                await marketsListViewModel.loadCoins()
            }
        }
    }
}



