import SwiftUI
import Charts

struct CoinChartView: View {
    let data: [PricePoint]
    @State private var selected: PricePoint?

    var body: some View {
        Chart {
            ForEach(data) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Price", point.price)
                )
                .foregroundStyle(.blue)
            }

            if let selected {
                // 🔹 Точка на графике
                PointMark(
                    x: .value("Date", selected.date),
                    y: .value("Price", selected.price)
                )
                .foregroundStyle(.red)
                .symbolSize(50)
                .annotation(position: .topLeading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selected.date, style: .date)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(selected.price, format: .currency(code: "USD"))")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.primary)
                    }
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white)        // ✅ Белый фон
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1) // ✅ тонкая граница
                    )
                    .shadow(radius: 2)
                }

                // 🔹 Вертикальная линия
                RuleMark(x: .value("Date", selected.date))
                    .foregroundStyle(.gray)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))

                // 🔹 Горизонтальная линия
                RuleMark(y: .value("Price", selected.price))
                    .foregroundStyle(.gray)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if let date: Date = proxy.value(atX: value.location.x) {
                                    // Находим ближайшую точку
                                    if let nearest = data.min(by: {
                                        abs($0.date.timeIntervalSince1970 - date.timeIntervalSince1970) <
                                        abs($1.date.timeIntervalSince1970 - date.timeIntervalSince1970)
                                    }) {
                                        selected = nearest
                                    }
                                }
                            }
                    )
            }
        }
        .frame(height: 280)
    }
}
