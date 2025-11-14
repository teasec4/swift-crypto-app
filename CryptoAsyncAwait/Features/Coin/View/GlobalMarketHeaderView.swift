import SwiftUI
import Combine

struct GlobalMarketHeaderView: View {
    @ObservedObject var viewModel: GlobalMarketViewModel
    var disableAutoLoad: Bool = false

    var body: some View {
        VStack {
            bodyContent
        }
        .task {
            if !disableAutoLoad {
                await viewModel.loadGlobalData()
            }
        }
    }

    @ViewBuilder
    private var bodyContent: some View {
        switch viewModel.state {
        case .loading:
            GlobalMarketSkeletonView()

        case .error(_):
            EmptyView()
    
        case .empty:
            Text("No data available")
                .foregroundColor(.gray)

        case .content(let data):
            HStack {
                Spacer()
                VStack {
                    Text("Global Market Cap")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack {
                        Text("$\(formatNumber(data.totalMarketCap?["usd"] ?? 0))")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text(String(format: "%+.2f%%", data.marketCapChangePercentage24hUsd ?? 0.0))
                            .font(.subheadline.bold())
                            .foregroundColor(data.marketCapChangePercentage24hUsd ?? 0.0 >= 0 ? .green : .red)
                            .transition(.opacity)
                    }
                }

                Spacer()

                VStack {
                    Text("24h Volume")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("$\(formatNumber(data.totalVolume?["usd"] ?? 0))")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }

                Spacer()
            }
        }
    }

    private func formatNumber(_ num: Double) -> String {
        switch num {
        case 1_000_000_000_000...:
            return String(format: "%.2fT", num / 1_000_000_000_000)
        case 1_000_000_000...:
            return String(format: "%.2fB", num / 1_000_000_000)
        case 1_000_000...:
            return String(format: "%.2fM", num / 1_000_000)
        default:
            return String(format: "%.0f", num)
        }
    }
}
