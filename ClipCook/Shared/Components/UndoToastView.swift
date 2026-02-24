import SwiftUI

struct UndoToastView: View {
    let message: String
    let onUndo: () -> Void

    var body: some View {
        HStack {
            Text(message)
                .font(AppTheme.bodyFont)
                .foregroundColor(.white)

            Spacer()

            Button("Undo") {
                onUndo()
            }
            .font(.system(size: 15, weight: .bold))
            .foregroundColor(AppTheme.primary)
        }
        .padding()
        .background(Color(.systemGray6).colorInvert())
        .cornerRadius(AppTheme.cornerRadiusSM)
        .shadow(radius: 8)
        .padding(.horizontal)
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let onUndo: () -> Void

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                VStack {
                    Spacer()
                    UndoToastView(message: message, onUndo: {
                        onUndo()
                        isPresented = false
                    })
                    .padding(.bottom, 80)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(), value: isPresented)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        isPresented = false
                    }
                }
            }
        }
    }
}

extension View {
    func undoToast(isPresented: Binding<Bool>, message: String, onUndo: @escaping () -> Void) -> some View {
        modifier(ToastModifier(isPresented: isPresented, message: message, onUndo: onUndo))
    }
}
