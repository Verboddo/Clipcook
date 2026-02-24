import SwiftUI

struct ShoppingListView: View {
    @State private var viewModel = ShoppingListViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            addItemBar
            content
        }
        .background(AppTheme.primaryBackground.ignoresSafeArea())
        .task { await viewModel.loadData() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Shopping List")
                .font(AppTheme.titleFont)
            Text("\(viewModel.items.count) items")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var addItemBar: some View {
        HStack(spacing: 10) {
            TextField("Add item...", text: $viewModel.newItemText)
                .font(AppTheme.bodyFont)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(AppTheme.cornerRadiusSM)
                .onSubmit { Task { await viewModel.addItem() } }

            Button { Task { await viewModel.addItem() } } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.primary)
                    .clipShape(Circle())
            }
        }
        .padding()
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.items.isEmpty {
            emptyState
        } else {
            filledState
        }
    }

    private var emptyState: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingMD) {
                Spacer().frame(height: 20)
                EmptyStateView(
                    title: "Your list is empty",
                    subtitle: "Add items or import from your saved recipes"
                )

                if !viewModel.recipes.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(viewModel.recipes.prefix(5)) { recipe in
                            Button {
                                Task { await viewModel.addFromRecipe(recipe) }
                            } label: {
                                Text("+ \(recipe.title)")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(AppTheme.primary)
                                    .lineLimit(1)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(AppTheme.primary.opacity(0.08))
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private var filledState: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.items) { item in
                        Button { Task { await viewModel.toggleItem(item) } } label: {
                            HStack(spacing: 12) {
                                Image(systemName: item.checked ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22))
                                    .foregroundColor(item.checked ? AppTheme.primary : Color(.systemGray3))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(AppTheme.bodyFont)
                                        .strikethrough(item.checked)
                                        .foregroundColor(item.checked ? AppTheme.secondaryText : .primary)

                                    if let recipeName = item.recipeName {
                                        Text("from \(recipeName)")
                                            .font(AppTheme.captionFont)
                                            .foregroundColor(AppTheme.secondaryText)
                                    }
                                }

                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .background(AppTheme.cardBackground)
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.leading, 54)
                    }
                }
            }

            if viewModel.hasCheckedItems {
                Button { Task { await viewModel.clearChecked() } } label: {
                    Text("Clear checked (\(viewModel.checkedCount))")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.destructive)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.destructive.opacity(0.08))
                        .cornerRadius(AppTheme.cornerRadiusSM)
                }
                .padding()
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var maxHeight: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > containerWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxHeight = currentY + lineHeight
        }

        return CGSize(width: containerWidth, height: maxHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
    }
}
