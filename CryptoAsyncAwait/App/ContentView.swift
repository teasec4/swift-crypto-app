

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            NavigationStack {
                CoinsPage()
                .navigationTitle("Coins")
                .navigationBarTitleDisplayMode(.inline)
                
            }
            
            .tabItem {
                Label("Coins", systemImage: "bitcoinsign.circle")
            }

            NavigationStack {
                ProfileView()
                    .navigationTitle("Profile center")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }

    }
    
}



