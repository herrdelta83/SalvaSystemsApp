import SwiftUI

struct RepoInputView: View {
    @Bindable var vm: EvaluationViewModel

    @State private var showTokenField = false
    @FocusState private var urlFieldFocused: Bool

    var body: some View {
        ZStack {
            darkBackground
            ScrollView {
                VStack(spacing: 36) {
                    heroSection
                    formSection
                }
                .padding(.top, 80)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
    }

    // MARK: - Background

    private var darkBackground: some View {
        ZStack {
            Color.black
            // Bokeh blobs matching the inspiration
            Circle()
                .fill(Color.orange.opacity(0.18))
                .frame(width: 260)
                .blur(radius: 80)
                .offset(x: -130, y: 80)
            Circle()
                .fill(Color.indigo.opacity(0.20))
                .frame(width: 220)
                .blur(radius: 80)
                .offset(x: 140, y: 20)
            Circle()
                .fill(Color.purple.opacity(0.12))
                .frame(width: 180)
                .blur(radius: 70)
                .offset(x: 20, y: 280)
        }
        .ignoresSafeArea()
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 20) {
            rainbowIcon
            VStack(spacing: 8) {
                Text("AccessFlow")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                Text("GitHub repo accessibility auditor\npowered by Apple Intelligence")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.50))
            }
        }
    }

    private var rainbowIcon: some View {
        ZStack(alignment: .bottomTrailing) {
            // Subtle glow behind icon
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.10), .clear],
                        center: .center, startRadius: 10, endRadius: 55
                    )
                )
                .frame(width: 110, height: 110)

            // Rainbow ring
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [.red, .orange, .yellow, .green, .cyan, .blue, .purple, .red],
                        center: .center
                    ),
                    lineWidth: 3
                )
                .frame(width: 88, height: 88)

            // Icon background
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 78, height: 78)
                .overlay(
                    Image(systemName: "accessibility")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(.white)
                )

            // Apple Intelligence status dot
            Circle()
                .fill(Color.green)
                .frame(width: 11, height: 11)
                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                .offset(x: 4, y: 4)
        }
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: 16) {
            urlField
            audiencePicker
            tokenSection
            if case .failed(let msg) = vm.state { errorBanner(msg) }
            analyzeButton
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Fields

    private var urlField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("GitHub Repository")
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.50))
            HStack(spacing: 12) {
                Image(systemName: "link")
                    .foregroundStyle(.white.opacity(0.40))
                    .frame(width: 18)
                TextField(
                    "",
                    text: $vm.repoURL,
                    prompt: Text("github.com/owner/repo")
                        .foregroundColor(Color(red: 0.45, green: 0.55, blue: 0.95).opacity(0.8))
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.URL)
                .focused($urlFieldFocused)
                .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    )
            )
        }
    }

    private var audiencePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Target Audience")
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.50))
            Menu {
                ForEach(TargetAudience.allCases) { audience in
                    Button {
                        vm.selectedAudience = audience
                    } label: {
                        Label(audience.displayName, systemImage: audience.icon)
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: vm.selectedAudience.icon)
                        .foregroundStyle(audienceAccent)
                        .frame(width: 18)
                    Text(vm.selectedAudience.displayName)
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.40))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.07))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(audienceAccent.opacity(0.35), lineWidth: 1)
                        )
                )
            }
        }
    }

    private var audienceAccent: Color {
        switch vm.selectedAudience {
        case .visualImpairment:    .cyan
        case .motorImpairment:     .green
        case .hearingImpairment:   .teal
        case .neurodivergence:     .purple
        case .elderly:             .blue
        case .cognitiveImpairment: .orange
        }
    }

    private var tokenSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { showTokenField.toggle() }
            } label: {
                HStack {
                    Label("GitHub Token (optional)", systemImage: "key.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.50))
                    Spacer()
                    Image(systemName: showTokenField ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.35))
                }
            }
            if showTokenField {
                SecureField("ghp_xxxxxxxxxxxxxxxxxxxx", text: $vm.githubToken)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.07))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
                            )
                    )
                Text("Stored in Keychain. Enables private repos and 5,000 req/hr.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.35))
            }
        }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.red.opacity(0.90))
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.red.opacity(0.25), lineWidth: 1))
    }

    private var analyzeButton: some View {
        Button {
            urlFieldFocused = false
            Task { await vm.startEvaluation() }
        } label: {
            Text("Analyze Repository")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Group {
                        if vm.repoURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            AnyShapeStyle(Color.white.opacity(0.10))
                        } else {
                            AnyShapeStyle(
                                LinearGradient(
                                    colors: [Color(red: 0.3, green: 0.4, blue: 1.0),
                                             Color(red: 0.6, green: 0.3, blue: 1.0)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                        }
                    },
                    in: RoundedRectangle(cornerRadius: 14)
                )
        }
        .disabled(vm.repoURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .padding(.top, 4)
    }
}
