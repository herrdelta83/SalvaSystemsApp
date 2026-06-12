import SwiftUI

@main
struct AccessFlowApp: App {
    @State private var vm = EvaluationViewModel()

    var body: some Scene {
        WindowGroup {
            rootView
                .animation(.easeInOut(duration: 0.35), value: vm.screenTag)
        }
    }

    @ViewBuilder
    private var rootView: some View {
        switch vm.state {
        case .idle, .failed:
            NavigationStack {
                RepoInputView(vm: vm)
            }
        case .loading, .analyzing:
            NavigationStack {
                EvaluationProgressView(vm: vm)
            }
        case .done:
            if let report = vm.report {
                NavigationStack {
                    ReportView(report: report) { vm.reset() }
                }
            }
        }
    }
}
