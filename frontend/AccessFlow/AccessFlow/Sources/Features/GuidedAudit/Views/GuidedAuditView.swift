import SwiftUI

struct GuidedAuditView: View {
    @Binding var path: NavigationPath
    @State private var vm = GuidedAuditViewModel()

    var body: some View {
        VStack(spacing: 0) {
            progressBar

            TabView(selection: $vm.currentStep) {
                step0.tag(0)
                step1.tag(1)
                step2.tag(2)
                step3.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: vm.currentStep)

            navigationButtons
                .padding(20)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Guided Audit")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle().fill(Color(.systemFill))
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: geo.size.width * CGFloat(vm.currentStep + 1) / CGFloat(vm.totalSteps + 1))
                    .animation(.spring(), value: vm.currentStep)
            }
        }
        .frame(height: 3)
    }

    // MARK: - Steps

    private var step0: some View {
        stepContainer(
            step: 1,
            icon: "list.bullet.clipboard",
            title: "What's the human task?",
            subtitle: "Describe what a real person is trying to do in the app."
        ) {
            TextEditor(text: $vm.taskDescription)
                .frame(minHeight: 100)
                .padding(12)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    Group {
                        if vm.taskDescription.isEmpty {
                            Text("e.g. Book an appointment for next Tuesday")
                                .foregroundStyle(.tertiary)
                                .padding(18)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                    }
                )
        }
    }

    private var step1: some View {
        stepContainer(
            step: 2,
            icon: "person.3.fill",
            title: "Who is affected?",
            subtitle: "Select the disability profile most impacted by this issue."
        ) {
            VStack(spacing: 10) {
                ForEach(UserProfile.allCases) { profile in
                    Button {
                        vm.selectedProfile = profile
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: profile.icon)
                                .font(.title3)
                                .foregroundStyle(vm.selectedProfile == profile ? .white : .blue)
                                .frame(width: 30)
                            Text(profile.rawValue)
                                .font(.subheadline)
                                .foregroundStyle(vm.selectedProfile == profile ? .white : .primary)
                            Spacer()
                            if vm.selectedProfile == profile {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(.white)
                            }
                        }
                        .padding(14)
                        .background(
                            vm.selectedProfile == profile ? AnyShapeStyle(Color.blue) : AnyShapeStyle(Color(.secondarySystemBackground)),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var step2: some View {
        stepContainer(
            step: 3,
            icon: "exclamationmark.triangle",
            title: "Describe the issue",
            subtitle: "What accessibility problem did you observe?"
        ) {
            VStack(spacing: 16) {
                TextEditor(text: $vm.issueDescription)
                    .frame(minHeight: 90)
                    .padding(12)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

                Toggle(isOn: $vm.blocksTask) {
                    Label("This issue completely blocks the task", systemImage: "xmark.circle")
                        .font(.subheadline)
                }
                .padding(14)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 10) {
                    Text("Estimated severity").font(.subheadline).fontWeight(.medium)
                    HStack(spacing: 8) {
                        ForEach(Severity.allCases) { s in
                            Button { vm.selectedSeverity = s } label: {
                                SeverityBadge(severity: s, compact: vm.selectedSeverity != s)
                                    .opacity(vm.selectedSeverity == s ? 1.0 : 0.5)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var step3: some View {
        stepContainer(
            step: 4,
            icon: "checkmark.circle.fill",
            title: "Ready to analyse",
            subtitle: "AccessFlow will score severity, detect patterns, and generate recommendations."
        ) {
            VStack(spacing: 12) {
                if !vm.collectedIssues.isEmpty {
                    Text("\(vm.collectedIssues.count) issue\(vm.collectedIssues.count == 1 ? "" : "s") collected")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Button {
                    vm.addCurrentIssue()
                    let report = vm.generateReport()
                    path.append(AppRoute.dashboard(report))
                } label: {
                    Label("Generate Analysis", systemImage: "brain")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.blue, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private func stepContainer<Content: View>(step: Int, icon: String, title: String,
                                              subtitle: String, @ViewBuilder content: () -> Content) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 12) {
                    Image(systemName: icon).font(.title2).foregroundStyle(.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Step \(step) of \(vm.totalSteps)").font(.caption).foregroundStyle(.secondary)
                        Text(title).font(.title3).fontWeight(.bold)
                    }
                }
                Text(subtitle).font(.body).foregroundStyle(.secondary)
                content()
            }
            .padding(20)
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if vm.currentStep > 0 {
                Button("Back") { vm.currentStep -= 1 }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            }

            if vm.currentStep < vm.totalSteps - 1 {
                Button("Next") { vm.currentStep += 1 }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(vm.isStepValid ? AnyShapeStyle(Color.blue) : AnyShapeStyle(Color(.systemFill)),
                                in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(vm.isStepValid ? .white : .secondary)
                    .disabled(!vm.isStepValid)
            }
        }
        .buttonStyle(.plain)
        .font(.subheadline).fontWeight(.semibold)
    }
}
