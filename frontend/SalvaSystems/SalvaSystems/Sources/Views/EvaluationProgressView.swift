import SwiftUI

struct EvaluationProgressView: View {
    var vm: EvaluationViewModel

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 32) {
                Spacer()
                iconView
                statusText
                progressSection
                Spacer()
                Spacer()
            }
            .padding(.horizontal, 32)
        }
        .navigationBarHidden(true)
    }

    // MARK: - Components

    private var iconView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.1)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
            Image(systemName: "accessibility")
                .font(.system(size: 52, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.pulse)
        }
    }

    @ViewBuilder
    private var statusText: some View {
        switch vm.state {
        case .loading(let message):
            VStack(spacing: 8) {
                Text("Fetching files…")
                    .font(.title2.bold())
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        case .analyzing(let fileName, _):
            VStack(spacing: 8) {
                Text("Analyzing…")
                    .font(.title2.bold())
                Text(fileName)
                    .font(.subheadline.monospaced())
                    .foregroundStyle(.indigo)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private var progressSection: some View {
        switch vm.state {
        case .analyzing(_, let progress):
            VStack(spacing: 10) {
                ProgressView(value: progress)
                    .tint(.blue)
                    .scaleEffect(x: 1, y: 2)
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        case .loading:
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.blue)
                .scaleEffect(1.3)
        default:
            EmptyView()
        }
    }
}
