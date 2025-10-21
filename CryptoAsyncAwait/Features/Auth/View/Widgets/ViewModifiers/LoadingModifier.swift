import SwiftUI

struct LoadingModifier: ViewModifier {
    @Binding var isVisible: Bool
    @State private var rotation: Double = 0

    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: isVisible ? 4 : 0)
                .animation(.easeInOut(duration: 0.25), value: isVisible)

            if isVisible {
                
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .overlay(
                        LinearGradient(
                            colors: [
                                .yellow.opacity(0.15),
                                .orange.opacity(0.1),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(
                                AngularGradient(
                                    gradient: Gradient(colors: [.yellow, .orange, .yellow]),
                                    center: .center
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: .orange.opacity(0.4), radius: 25)
                            .rotationEffect(.degrees(rotation))
                            .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: rotation)

                        Image(systemName: "bitcoinsign.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(28)
                            .foregroundStyle(.white)
                            .shadow(color: .yellow.opacity(0.8), radius: 10)
                    }
                    .onAppear { rotation = 360 }
                    .onDisappear { rotation = 0 }

                    Text("Fetching market data...")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .transition(.opacity)
                }
                .padding(.bottom, 60)
                .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isVisible)
    }
}

extension View {
    func contentLoading(isVisible: Binding<Bool>) -> some View {
        modifier(LoadingModifier(isVisible: isVisible))
    }
}
