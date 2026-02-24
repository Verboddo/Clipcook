import SwiftUI

struct CookModeView: View {
    @State private var viewModel: CookModeViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    init(recipe: Recipe) {
        _viewModel = State(initialValue: CookModeViewModel(recipe: recipe))
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            progressSection
            Spacer()
            stepContent
            Spacer()
            timerCard
            navigationButtons
        }
        .background(AppTheme.primaryBackground.ignoresSafeArea())
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            viewModel.cleanup()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                viewModel.scheduleBackgroundNotification()
            } else if newPhase == .active {
                viewModel.cancelNotifications()
            }
        }
        .overlay {
            if viewModel.showCompletionToast {
                completionOverlay
            }
        }
    }

    private var headerSection: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 36, height: 36)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("COOK MODE")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(2)
                    .foregroundColor(AppTheme.primary)
                Text(viewModel.recipe.title)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.secondaryText)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundColor(AppTheme.primary)
                    .font(.system(size: 14))
                Text("\(viewModel.completedSteps.count)/\(viewModel.totalSteps)")
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var progressSection: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                    Capsule()
                        .fill(AppTheme.primary)
                        .frame(width: geo.size.width * viewModel.progress)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.progress)
                }
            }
            .frame(height: 6)

            HStack {
                Text("Step \(viewModel.currentStepIndex + 1) of \(viewModel.totalSteps)")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
                Spacer()
                Text("\(viewModel.progressPercentage)%")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var stepContent: some View {
        VStack(spacing: AppTheme.spacingLG) {
            Text("\(viewModel.currentStepIndex + 1)")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(AppTheme.primary)
                .clipShape(Circle())

            if let step = viewModel.currentStep {
                Text(step.text)
                    .font(.system(size: 20, weight: .medium))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.spacingLG)
            }
        }
        .padding(.horizontal)
    }

    private var timerCard: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "timer")
                        .foregroundColor(AppTheme.primary)
                    Text("Step Timer")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.secondaryText)
                }
                Spacer()
                Button { viewModel.resetTimer() } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .foregroundColor(AppTheme.secondaryText)
                }
            }

            HStack {
                Text(viewModel.timerDisplay)
                    .font(.system(size: 42, weight: .medium, design: .monospaced))

                Spacer()

                Button {
                    if viewModel.timerRunning {
                        viewModel.pauseTimer()
                    } else {
                        viewModel.startTimer()
                    }
                } label: {
                    Image(systemName: viewModel.timerRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(AppTheme.primary)
                        .clipShape(Circle())
                }
                .accessibilityLabel(viewModel.timerRunning ? "Pause timer" : "Start timer")
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        .padding(.horizontal)
    }

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            Button { viewModel.previousStep() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            .disabled(viewModel.currentStepIndex == 0)
            .opacity(viewModel.currentStepIndex == 0 ? 0.4 : 1)

            Button { viewModel.completeCurrentStep() } label: {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.isLastStep ? "checkmark" : "checkmark")
                    Text(viewModel.isLastStep ? "Finish Recipe" : "Done — Next Step")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(viewModel.isLastStep ? Color.green : AppTheme.primary)
                .cornerRadius(AppTheme.cornerRadius)
            }

            Button { viewModel.nextStep() } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            .disabled(viewModel.isLastStep)
            .opacity(viewModel.isLastStep ? 0.4 : 1)
        }
        .padding()
    }

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 16) {
                ChefMascotView(mood: .excited, size: 80)
                Text("Recipe complete!")
                    .font(.system(size: 22, weight: .bold))
                Text("Enjoy your meal!")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.secondaryText)
                Button("Done") { dismiss() }
                    .buttonStyle(AppButtonStyle())
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
            }
            .padding(32)
            .background(.ultraThickMaterial)
            .cornerRadius(AppTheme.cornerRadiusLG)
        }
        .transition(.opacity)
    }
}
