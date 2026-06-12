import SwiftUI
import UniformTypeIdentifiers

struct AuditImportView: View {
    @Binding var path: NavigationPath
    @State private var vm = AuditImportViewModel()
    @State private var showFilePicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                importHeader
                sampleSection
                fileSection
                if let error = vm.importError { errorCard(error) }
            }
            .padding(20)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Import Report")
        .navigationBarTitleDisplayMode(.large)
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first { vm.importFile(url: url) }
            case .failure(let err):
                vm.importError = err.localizedDescription
            }
        }
    }

    // MARK: - Header

    private var importHeader: some View {
        HStack(spacing: 14) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 36))
                .foregroundStyle(.teal)
            VStack(alignment: .leading, spacing: 4) {
                Text("Import a Report")
                    .font(.headline)
                Text("Load an .accessflow.json file exported from\nXcodeGen, Xcode, or the AccessFlow CLI.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.secondarySystemBackground, in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Sample

    private var sampleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preloaded samples").font(.headline)

            Button {
                path.append(AppRoute.dashboard(vm.loadSample()))
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue.opacity(0.12))
                            .frame(width: 48, height: 48)
                        Image(systemName: "heart.text.square")
                            .font(.title3).foregroundStyle(.blue)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("HealthConnect v1.1.0")
                            .font(.subheadline).fontWeight(.semibold).foregroundStyle(.primary)
                        Text("10 issues · 2 critical · Do Not Ship")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
                }
                .padding(16)
                .background(.secondarySystemBackground, in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - File Import

    private var fileSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Import from file").font(.headline)

            Button {
                showFilePicker = true
            } label: {
                Label("Choose .accessflow.json", systemImage: "folder.badge.plus")
                    .font(.subheadline).fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.teal.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.teal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(.teal.opacity(0.3), lineWidth: 1)
                    )
            }
        }
    }

    // MARK: - Error

    private func errorCard(_ message: String) -> some View {
        Label(message, systemImage: "exclamationmark.triangle.fill")
            .font(.caption)
            .foregroundStyle(.red)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
    }
}
