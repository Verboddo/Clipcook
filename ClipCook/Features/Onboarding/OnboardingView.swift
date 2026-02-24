import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let slides: [(mood: ChefMood, icons: String, title: String, description: String)] = [
        (.happy, "🧇🍪", "Clip It", "Save recipes from Instagram with a single tap. Just paste a link or share directly."),
        (.cooking, "🍳🔍", "Cook It", "Edit ingredients, adjust servings, and follow step-by-step instructions."),
        (.wink, "❤️🍪", "Keep It", "Build your collection, plan meals, and never lose a recipe again."),
    ]

    var body: some View {
        ZStack {
            AppTheme.primaryBackground.ignoresSafeArea()

            FloatingBubblesView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("CLIPCOOK")
                    .font(.system(size: 14, weight: .semibold))
                    .tracking(4)
                    .foregroundStyle(AppTheme.primary)
                    .padding(.top, 60)

                TabView(selection: $currentPage) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        slideContent(index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                pageIndicator
                    .padding(.bottom, AppTheme.spacingLG)

                actionButton
                    .padding(.horizontal, AppTheme.spacingLG)

                if currentPage < 2 {
                    Button("Skip") {
                        hasCompletedOnboarding = true
                    }
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.secondaryText)
                    .padding(.top, AppTheme.spacingMD)
                }

                Spacer().frame(height: 40)
            }
        }
    }

    private func slideContent(index: Int) -> some View {
        let slide = slides[index]
        return VStack(spacing: AppTheme.spacingMD) {
            Spacer()

            ChefMascotView(mood: slide.mood, size: 100)

            Text(slide.icons)
                .font(.system(size: 28))

            Text(slide.title)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.primary)

            Text(slide.description)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? AppTheme.primary : Color(.systemGray4))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }

    private var actionButton: some View {
        Button {
            if currentPage < 2 {
                withAnimation(reduceMotion ? nil : .easeInOut) { currentPage += 1 }
            } else {
                hasCompletedOnboarding = true
            }
        } label: {
            Text(currentPage < 2 ? "Next" : "Get Started")
        }
        .buttonStyle(AppButtonStyle())
    }
}

struct FloatingBubblesView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let bubbles: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = [
        (0.10, 0.15, 12, 0.15),
        (0.85, 0.10, 10, 0.12),
        (0.75, 0.20, 14, 0.10),
        (0.20, 0.40, 8, 0.15),
        (0.90, 0.35, 11, 0.12),
        (0.15, 0.60, 10, 0.10),
        (0.80, 0.55, 13, 0.15),
        (0.50, 0.70, 9, 0.10),
        (0.30, 0.80, 11, 0.12),
        (0.70, 0.75, 8, 0.10),
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<bubbles.count, id: \.self) { i in
                let b = bubbles[i]
                Circle()
                    .fill(Color(.systemGray4))
                    .frame(width: b.size, height: b.size)
                    .opacity(b.opacity)
                    .position(
                        x: geo.size.width * b.x,
                        y: geo.size.height * b.y
                    )
            }
        }
    }
}
