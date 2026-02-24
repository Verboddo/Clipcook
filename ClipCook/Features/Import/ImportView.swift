import SwiftUI

struct ImportView: View {
    @State private var viewModel = ImportViewModel()
    @Environment(\.dismiss) private var dismiss
    var onRecipeSaved: ((Recipe) -> Void)?
    @State private var recipeToEdit: Recipe?
    @State private var showManualPaste = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            header
            urlInput
            importButton

            switch viewModel.state {
            case .loading:
                loadingState
            case .error(let message):
                errorState(message)
            default:
                EmptyView()
            }

            shareExtensionInfo
            Spacer()
        }
        .padding()
        .background(AppTheme.primaryBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: previewBinding) {
            if let recipe = viewModel.previewRecipe {
                previewSheet(recipe: recipe)
            }
        }
        .fullScreenCover(item: $recipeToEdit) { recipe in
            NavigationStack {
                RecipeEditView(recipe: recipe)
            }
        }
    }

    private var previewBinding: Binding<Bool> {
        Binding(
            get: {
                if case .preview = viewModel.state { return true }
                return false
            },
            set: { if !$0 { viewModel.state = .idle } }
        )
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
            }
            Text("Import Recipe")
                .font(AppTheme.titleFont)
            Spacer()
        }
    }

    private var urlInput: some View {
        HStack(spacing: 10) {
            Image(systemName: "link")
                .foregroundStyle(AppTheme.secondaryText)
            TextField("Paste Instagram link...", text: $viewModel.urlText)
                .font(AppTheme.bodyFont)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .textContentType(.URL)
        }
        .padding(14)
        .background(Color(.systemGray6))
        .clipShape(.rect(cornerRadius: AppTheme.cornerRadiusSM))
    }

    private var importButton: some View {
        Button {
            Task { await viewModel.importURL() }
        } label: {
            Text("Import")
        }
        .buttonStyle(AppButtonStyle())
        .disabled(!viewModel.canImport)
        .opacity(viewModel.canImport ? 1.0 : 0.6)
    }

    private var loadingState: some View {
        VStack(spacing: AppTheme.spacingMD) {
            ChefMascotView(mood: .cooking, size: 70)
            Text("Fetching your recipe...")
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.secondaryText)
            ProgressView()
                .tint(AppTheme.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.spacingXL)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: AppTheme.spacingMD) {
            ChefMascotView(mood: .sad, size: 60)

            Text("Couldn't retrieve metadata")
                .font(AppTheme.subheadlineFont)
                .foregroundStyle(AppTheme.destructive)

            Text("We weren't able to extract recipe data from this link. You can try a different URL or enter the recipe details yourself.")
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                Button("Try Again") { viewModel.clearError() }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)

                Button {
                    Task {
                        if let recipe = await viewModel.createBlankRecipe() {
                            recipeToEdit = recipe
                        }
                    }
                } label: {
                    Text("Edit Manually")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(AppTheme.primary)
                        .clipShape(.rect(cornerRadius: AppTheme.cornerRadiusSM))
                }
            }
        }
        .padding()
        .background(AppTheme.destructive.opacity(0.06))
        .clipShape(.rect(cornerRadius: AppTheme.cornerRadius))
    }

    private var shareExtensionInfo: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.primary)
                Text("Also works via Share Extension")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            HStack(spacing: 12) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.purple)
                    .frame(width: 36, height: 36)
                    .background(Color.purple.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 8))

                VStack(alignment: .leading) {
                    Text("Instagram")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Share → ClipCook")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Spacer()

                Text("Import")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.primary.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 8))
            }
            .padding(12)
            .background(AppTheme.cardBackground)
            .clipShape(.rect(cornerRadius: AppTheme.cornerRadiusSM))
        }
        .padding()
        .background(AppTheme.primaryLight.opacity(0.3))
        .clipShape(.rect(cornerRadius: AppTheme.cornerRadius))
    }

    // MARK: - Preview Sheet

    private func previewSheet(recipe: Recipe) -> some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingMD) {
                Capsule()
                    .fill(Color(.systemGray4))
                    .frame(width: 36, height: 5)
                    .padding(.top, 10)

                previewImage(recipe)
                    .frame(height: 180)
                    .clipped()
                    .clipShape(.rect(cornerRadius: AppTheme.cornerRadius))
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 6) {
                    Text(recipe.title)
                        .font(.system(size: 20, weight: .bold))
                        .lineLimit(3)

                    if let sourceUrl = recipe.sourceUrl {
                        Text(sourceUrl)
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.primary)
                            .lineLimit(1)
                    }

                    HStack(spacing: 8) {
                        if let platform = recipe.sourcePlatform {
                            Text(platform.rawValue.capitalized)
                                .font(AppTheme.badgeFont)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppTheme.primary.opacity(0.12))
                                .foregroundStyle(AppTheme.primary)
                                .clipShape(.rect(cornerRadius: 6))
                        }
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)

                captionSection

                if let parsed = viewModel.parsedResult, parsed.hasContent {
                    parsedResultBadges(parsed)
                }

                actionButtons(recipe)

                Button("Cancel") {
                    viewModel.state = .idle
                }
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.primary)
                .padding(.bottom, AppTheme.spacingMD)
            }
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: - Caption Section

    @ViewBuilder
    private var captionSection: some View {
        switch viewModel.captionExtractionState {
        case .extracting:
            extractingIndicator
        case .completed:
            extractionCompletedSection
        case .failed:
            extractionFailedSection
        case .idle:
            if !viewModel.isInstagram {
                manualPasteSection
            }
        }
    }

    private var extractingIndicator: some View {
        HStack(spacing: 10) {
            ProgressView()
                .tint(AppTheme.primary)
            Text("Extracting recipe details...")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.primaryLight.opacity(0.3))
        .clipShape(.rect(cornerRadius: AppTheme.cornerRadius))
        .padding(.horizontal)
    }

    private var extractionCompletedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.success)
                Text("Recipe details extracted automatically")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)
            }

            DisclosureGroup("Override with manual paste", isExpanded: $showManualPaste) {
                manualPasteContent
            }
            .font(.system(size: 13))
            .foregroundStyle(AppTheme.secondaryText)
        }
        .padding()
        .background(AppTheme.success.opacity(0.06))
        .clipShape(.rect(cornerRadius: AppTheme.cornerRadius))
        .padding(.horizontal)
    }

    private var extractionFailedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.orange)
                Text("Couldn't auto-extract — paste the caption manually")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)
            }

            manualPasteContent
        }
        .padding()
        .background(Color.orange.opacity(0.06))
        .clipShape(.rect(cornerRadius: AppTheme.cornerRadius))
        .padding(.horizontal)
    }

    private var manualPasteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "doc.on.clipboard")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.primary)
                Text("Paste the caption to extract ingredients & steps")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)
            }

            manualPasteContent
        }
        .padding()
        .background(AppTheme.primaryLight.opacity(0.3))
        .clipShape(.rect(cornerRadius: AppTheme.cornerRadius))
        .padding(.horizontal)
    }

    private var manualPasteContent: some View {
        VStack(spacing: 8) {
            TextEditor(text: $viewModel.captionText)
                .font(.system(size: 14))
                .frame(minHeight: 100, maxHeight: 160)
                .padding(8)
                .background(Color(.systemGray6))
                .clipShape(.rect(cornerRadius: AppTheme.cornerRadiusSM))
                .overlay(
                    Group {
                        if viewModel.captionText.isEmpty {
                            Text("Open the Instagram post → tap ··· → Copy text, then paste here")
                                .font(.system(size: 13))
                                .foregroundStyle(Color(.systemGray3))
                                .padding(12)
                        }
                    },
                    alignment: .topLeading
                )

            Button {
                viewModel.parseCaption()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "wand.and.stars")
                    Text("Extract Recipe")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(AppButtonStyle())
            .disabled(!viewModel.canParseCaption)
            .opacity(viewModel.canParseCaption ? 1.0 : 0.5)
        }
    }

    private func parsedResultBadges(_ parsed: ParsedRecipe) -> some View {
        HStack(spacing: 10) {
            resultBadge(
                icon: "carrot",
                count: parsed.ingredients.count,
                label: "ingredients"
            )
            resultBadge(
                icon: "list.number",
                count: parsed.steps.count,
                label: "steps"
            )
        }
        .padding(.horizontal)
    }

    private func resultBadge(icon: String, count: Int, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text("\(count) \(label)")
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundStyle(count > 0 ? AppTheme.success : AppTheme.secondaryText)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(count > 0 ? AppTheme.success.opacity(0.1) : Color(.systemGray5))
        .clipShape(.rect(cornerRadius: 8))
    }

    private func actionButtons(_ recipe: Recipe) -> some View {
        VStack(spacing: 10) {
            if recipe.ingredients.isEmpty && recipe.steps.isEmpty
                && viewModel.parsedResult == nil
                && viewModel.captionExtractionState != .extracting {
                Text("Paste the Instagram caption above to auto-detect ingredients and steps, or save manually.")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            HStack(spacing: 12) {
                Button {
                    Task {
                        if let saved = await viewModel.saveForEditing() {
                            viewModel.state = .idle
                            recipeToEdit = saved
                        }
                    }
                } label: {
                    Text("Edit & Save")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(AppButtonStyle(isPrimary: false))

                Button {
                    Task {
                        if let saved = await viewModel.saveAsIs() {
                            onRecipeSaved?(saved)
                        }
                    }
                } label: {
                    Text(recipe.ingredients.isEmpty ? "Save as-is" : "Save")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(AppButtonStyle())
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func previewImage(_ recipe: Recipe) -> some View {
        if let uiImage = viewModel.previewImage {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Rectangle()
                .fill(Color(.systemGray5))
                .overlay {
                    VStack(spacing: 4) {
                        Image(systemName: "photo")
                            .font(.system(size: 28))
                        Text("No image available")
                            .font(AppTheme.captionFont)
                    }
                    .foregroundStyle(Color(.systemGray3))
                }
        }
    }
}
