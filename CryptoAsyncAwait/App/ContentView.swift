

import SwiftUI

struct ContentView: View {
    @State private var selected = 0
    @State private var coinsPage = CoinsPage()
    @State private var profilePage = ProfileView()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // оба экрана живут постоянно
            ZStack {
                NavigationStack {
                    coinsPage
                        .navigationTitle("Coins")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .opacity(selected == 0 ? 1 : 0)
                .allowsHitTesting(selected == 0)
                .animation(nil, value: selected)

                NavigationStack {
                    profilePage
                        .navigationTitle("Profile center")
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



