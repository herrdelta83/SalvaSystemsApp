import SwiftUI

struct ReportView: View {
    let report: EvaluationReport
    let onDismiss: () -> Void

    @State private var selectedCriterion: AccessibilityCriterion?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard
                criteriaGrid
                if let criterion = selectedCriterion {
                    suggestionsCard(for: criterion)
                }
                fileList
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .safeAreaInset(edge: .bottom) { analyzeAnotherButton }
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(report.repositoryName)
                        .font(.headline)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Label(report.audience.displayName, systemImage: report.audience.icon)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                scoreRing(score: report.globalScore, size: 72)
            }
            Divider()
            HStack {
                scoreLabel(title: "Files analyzed", value: "\(report.records.count)")
                Spacer()
                scoreLabel(title: "Criteria", value: "\(AccessibilityCriterion.allCases.count)")
                Spacer()
                scoreLabel(title: "Global score", value: String(format: "%.0f", report.globalScore))
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Criteria grid

    private var criteriaGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Criteria")
                .font(.headline)
                .padding(.horizontal, 4)
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 10
            ) {
                ForEach(report.prioritizedCriteria) { criterion in
                    let avg = report.criterionAverages[criterion] ?? 0
                    criterionTile(criterion: criterion, score: avg)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCriterion = selectedCriterion == criterion ? nil : criterion
                            }
                        }
                }
            }
        }
    }

    private func criterionTile(criterion: AccessibilityCriterion, score: Double) -> some View {
        let isSelected = selectedCriterion == criterion
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: criterion.icon)
                    .foregroundStyle(scoreColor(score))
                Spacer()
                Text(String(format: "%.0f", score))
                    .font(.title3.bold().monospacedDigit())
                    .foregroundStyle(scoreColor(score))
            }
            Text(criterion.displayName)
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(2)
            ProgressView(value: score / 100)
                .tint(scoreColor(score))
        }
        .padding(12)
        .background(
            isSelected
                ? scoreColor(score).opacity(0.12)
                : Color(.secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 12)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? scoreColor(score).opacity(0.5) : Color.clear, lineWidth: 1.5)
        )
    }

    // MARK: - Suggestions card

    private func suggestionsCard(for criterion: AccessibilityCriterion) -> some View {
        let suggestions = report.suggestions(for: criterion)
        return VStack(alignment: .leading, spacing: 12) {
            Label("Top suggestions — \(criterion.displayName)", systemImage: criterion.icon)
                .font(.subheadline.weight(.semibold))
            if suggestions.isEmpty {
                Text("No critical issues found for this criterion.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(suggestions.enumerated()), id: \.offset) { _, suggestion in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                            .padding(.top, 2)
                        Text(suggestion)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - File list

    private var fileList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Files")
                .font(.headline)
                .padding(.horizontal, 4)
            ForEach(report.records.sorted { $0.averageScore < $1.averageScore }) { record in
                fileTile(record)
            }
        }
    }

    private func fileTile(_ record: FileEvaluationRecord) -> some View {
        HStack(spacing: 12) {
            scoreRing(score: record.averageScore, size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(record.fileName)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(record.path)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.head)
            }
            Spacer()
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Bottom bar

    private var analyzeAnotherButton: some View {
        Button(action: onDismiss) {
            Label("Analyze Another Repository", systemImage: "arrow.counterclockwise")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue, in: RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    // MARK: - Helpers

    private func scoreRing(score: Double, size: CGFloat) -> some View {
        ZStack {
            Circle()
                .stroke(scoreColor(score).opacity(0.2), lineWidth: size * 0.1)
            Circle()
                .trim(from: 0, to: score / 100)
                .stroke(scoreColor(score), style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(String(format: "%.0f", score))
                .font(.system(size: size * 0.28, weight: .bold).monospacedDigit())
                .foregroundStyle(scoreColor(score))
        }
        .frame(width: size, height: size)
    }

    private func scoreLabel(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.bold().monospacedDigit())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func scoreColor(_ score: Double) -> Color {
        switch score {
        case 80...100: .green
        case 50..<80:  .orange
        default:       .red
        }
    }
}
