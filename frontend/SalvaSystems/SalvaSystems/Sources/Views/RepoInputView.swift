import SwiftUI

struct RepoInputView: View {
    @Bindable var vm: EvaluationViewModel

    @State private var showTokenField = false
    @FocusState private var urlFieldFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection
                formSection
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
    }

    // MARK: - Sections

    private var heroSection: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.85), Color.purple.opacity(0.70)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            VStack(spacing: 12) {
                Image(systemName: "accessibility")
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundStyle(.white)
                Text("AccessFlow")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                Text("GitHub repo accessibility auditor\npowered by Apple Intelligence")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(.top, 80)
            .padding(.bottom, 40)
            .padding(.horizontal, 24)
        }
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [.clear, Color(.systemBackground)],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 60)
        }
    }

    private var formSection: some View {
        VStack(spacing: 20) {
            urlField
            audiencePicker
            tokenSection
            if case .failed(let msg) = vm.state { errorBanner(msg) }
            analyzeButton
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
    }

    // MARK: - Form components

    private var urlField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("GitHub Repository", systemImage: "link")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
            TextField("github.com/owner/repo", text: $vm.repoURL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.URL)
                .focused($urlFieldFocused)
                .padding()
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private var audiencePicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Target Audience", systemImage: "person.2.fill")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
            Menu {
                ForEach(TargetAudience.allCases) { audience in
                    Button {
                        vm.selectedAudience = audience
                    } label: {
                        Label(audience.displayName, systemImage: audience.icon)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: vm.selectedAudience.icon)
                        .foregroundStyle(.blue)
                    Text(vm.selectedAudience.displayName)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var tokenSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { showTokenField.toggle() }
            } label: {
                HStack {
                    Label("GitHub Token (optional)", systemImage: "key.fill")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: showTokenField ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            if showTokenField {
                SecureField("ghp_xxxxxxxxxxxxxxxxxxxx", text: $vm.githubToken)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                Text("Used for private repos and higher rate limits. Stored in Keychain.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.red)
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    private var analyzeButton: some View {
        Button {
            urlFieldFocused = false
            Task { await vm.startEvaluation() }
        } label: {
            Label("Analyze Repository", systemImage: "magnifyingglass")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    vm.repoURL.isEmpty
                        ? Color.blue.opacity(0.4)
                        : Color.blue,
                    in: RoundedRectangle(cornerRadius: 14)
                )
        }
        .disabled(vm.repoURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
}
