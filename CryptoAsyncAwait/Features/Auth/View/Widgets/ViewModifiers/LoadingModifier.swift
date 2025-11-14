import SwiftUI

struct LoadingModifier: ViewModifier {
    @Binding var isVisible: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isVisible)
                .opacity(isVisible ? 0.5 : 1)

            if isVisible {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.yellow)
            }
        }
    }
}

extension View {
    func contentLoading(isVisible: Binding<Bool>) -> some View {
        modifier(LoadingModifier(isVisible: isVisible))
    }
}
