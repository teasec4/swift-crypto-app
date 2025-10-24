

import SwiftUI

struct ContentView: View {
    // repository already initialized in ViewModel by defoult
    @StateObject private var globalMarketViewModel = GlobalMarketViewModel()
    @StateObject private var coinListViewModel = CoinListViewModel()
    @StateObject private var assetsViewModel = AssetsViewModel()
    
    // for custom tab bar
    @State private var selected = 0
       
       var body: some View {
           ZStack(alignment: .bottom) {
               ZStack {
                   NavigationStack {
                       CoinsPage(
                           globalMarketViewModel: globalMarketViewModel,
                           coinListViewModel: coinListViewModel,
                           assetsViewModel: assetsViewModel
                       )
                       .navigationTitle("Coins")
                       .navigationBarTitleDisplayMode(.inline)
                   }
                   .opacity(selected == 0 ? 1 : 0)
                   .allowsHitTesting(selected == 0)
                   .animation(nil, value: selected)
                   
                   NavigationStack {
                       AssetsView(coinListViewModel: coinListViewModel, assetsViewModel:assetsViewModel)
                           .navigationTitle("Assets")
                           .navigationBarTitleDisplayMode(.inline)
                   }
                   .opacity(selected == 1 ? 1 : 0)
                   .animation(nil, value: selected)
               }
               .transition(.identity)
               .animation(.none, value: selected)

               CustomTabBar(selected: $selected)
           }
           .background(Color.black.ignoresSafeArea())
           .ignoresSafeArea(.keyboard, edges: .bottom)
       }
}



