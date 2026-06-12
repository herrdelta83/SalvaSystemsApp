import SwiftUI

struct HomeView: View {
    @Binding var path: NavigationPath
    @State private var vm = HomeViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection

                differentiatorSection
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)

                actionsSection
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.85), Color.purple.opacity(0.70)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

            VStack(spacing: 14) {
                Image(systemName: "accessibility")
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundStyle(.white)
                    .symbolEffect(.pulse)

                Text("AccessFlow")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)

                Text("AI-powered accessibility auditing\nfor iOS teams that care.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.88))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.vertical, 80)
            .padding(.horizontal, 24)
        }
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [.clear, Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 180)
        }
    }

    // MARK: - Differentiator

    private var differentiatorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What makes AccessFlow different?")
                .font(.headline)

            ForEach(differentiators, id: \.0) { icon, title, desc in
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(.blue)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title).font(.subheadline).fontWeight(.semibold)
                        Text(desc).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private let differentiators: [(String, String, String)] = [
        ("brain", "Understands human tasks", "Identifies what real people can't do — not just which WCAG rule was violated."),
        ("person.3", "Profiles affected users", "Pinpoints which disability groups are impacted and how severely."),
        ("chart.bar.xaxis", "Calculates severity", "Weighted scoring model prioritises issues by release risk."),
        ("arrow.triangle.2.circlepath", "Detects regressions", "Compares versions and flags new failures before they ship.")
    ]

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: 14) {
            Text("Get started")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            actionButton(
                icon: "doc.text.magnifyingglass",
                title: "Load Sample Report",
                subtitle: "See a demo audit of HealthConnect v1.1",
                color: .blue
            ) {
                path.append(AppRoute.dashboard(vm.loadSampleReport()))
            }

            actionButton(
                icon: "list.clipboard",
                title: "Create Guided Audit",
                subtitle: "Step-by-step manual flow — no automation needed",
                color: .purple
            ) {
                path.append(AppRoute.guidedAudit)
            }

            actionButton(
                icon: "square.and.arrow.down",
                title: "Import Report",
                subtitle: "Load an .accessflow.json file",
                color: .teal
            ) {
                path.append(AppRoute.auditImport)
            }
        }
    }

    private func actionButton(
        icon: String, title: String, subtitle: String,
        color: Color, action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline).fontWeight(.semibold).foregroundStyle(.primary)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
