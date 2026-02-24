import Foundation
import UserNotifications

@Observable
final class CookModeViewModel {
    let recipe: Recipe
    var currentStepIndex = 0
    var completedSteps: Set<Int> = []
    var timerSeconds = 0
    var timerRunning = false
    var showCompletionToast = false

    private var timerTask: Task<Void, Never>?

    var sortedSteps: [Step] {
        recipe.steps.sorted { $0.order < $1.order }
    }

    var totalSteps: Int { sortedSteps.count }

    var currentStep: Step? {
        guard currentStepIndex < sortedSteps.count else { return nil }
        return sortedSteps[currentStepIndex]
    }

    var progress: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(completedSteps.count) / Double(totalSteps)
    }

    var progressPercentage: Int {
        Int(progress * 100)
    }

    var isLastStep: Bool {
        currentStepIndex == totalSteps - 1
    }

    var timerDisplay: String {
        let minutes = timerSeconds / 60
        let seconds = timerSeconds % 60
        return String(format: "%02d : %02d", minutes, seconds)
    }

    init(recipe: Recipe) {
        self.recipe = recipe
    }

    func startTimer() {
        timerRunning = true
        timerTask = Task { @MainActor in
            while timerRunning && !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if timerRunning {
                    timerSeconds += 1
                }
            }
        }
    }

    func pauseTimer() {
        timerRunning = false
        timerTask?.cancel()
    }

    func resetTimer() {
        pauseTimer()
        timerSeconds = 0
    }

    func completeCurrentStep() {
        completedSteps.insert(currentStepIndex)
        if isLastStep {
            pauseTimer()
            showCompletionToast = true
        } else {
            nextStep()
        }
    }

    func nextStep() {
        guard currentStepIndex < totalSteps - 1 else { return }
        currentStepIndex += 1
        resetTimer()
    }

    func previousStep() {
        guard currentStepIndex > 0 else { return }
        currentStepIndex -= 1
        resetTimer()
    }

    func scheduleBackgroundNotification() {
        guard timerRunning, timerSeconds > 0 else { return }
        let content = UNMutableNotificationContent()
        content.title = "Step \(currentStepIndex + 1) Timer"
        content.body = "Timer is still running for \(recipe.title)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "cook-timer-\(currentStepIndex)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func cleanup() {
        pauseTimer()
        cancelNotifications()
    }
}
