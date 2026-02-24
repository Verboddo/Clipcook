import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Environment(AuthService.self) private var authService
    @State private var showEmailForm = false
    @State private var showGoogleAlert = false
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ChefMascotView(mood: .happy, size: 90)
                .padding(.bottom, AppTheme.spacingLG)

            Text("Welcome to ClipCook")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.primary)

            Text("Sign in to save your recipes")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
                .padding(.top, 4)

            Spacer()

            VStack(spacing: AppTheme.spacingMD) {
                googleSignInButton

                appleSignInButton

                Text("or")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)

                Button {
                    showEmailForm = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 18))
                        Text("Continue with Email")
                    }
                }
                .buttonStyle(AppButtonStyle(isPrimary: false))
            }
            .padding(.horizontal, AppTheme.spacingLG)

            if let error = authService.errorMessage {
                Text(error)
                    .font(AppTheme.captionFont)
                    .foregroundColor(.red)
                    .padding(.top, AppTheme.spacingSM)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                .font(.system(size: 11))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, AppTheme.spacingLG)
                .padding(.bottom, 30)
        }
        .background(AppTheme.primaryBackground.ignoresSafeArea())
        .sheet(isPresented: $showEmailForm) {
            EmailSignInSheet(email: $email, password: $password)
        }
        .alert("Coming Soon", isPresented: $showGoogleAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Google Sign-In will be available in a future update.")
        }
    }

    private var googleSignInButton: some View {
        Button {
            showGoogleAlert = true
        } label: {
            HStack(spacing: 10) {
                Text("G")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .red, .yellow, .green],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text("Continue with Google")
            }
        }
        .buttonStyle(AppButtonStyle(isPrimary: false))
    }

    private var appleSignInButton: some View {
        SignInWithAppleButton(.signIn) { request in
            let nonce = authService.prepareAppleNonce()
            request.requestedScopes = [.fullName, .email]
            request.nonce = nonce
        } onCompletion: { result in
            authService.handleAppleSignIn(result: result)
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 52)
        .cornerRadius(AppTheme.cornerRadius)
    }
}

struct EmailSignInSheet: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss
    @Binding var email: String
    @Binding var password: String
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.spacingMD) {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)

                Button {
                    isLoading = true
                    Task {
                        await authService.signInWithEmail(email: email, password: password)
                        isLoading = false
                        if authService.isAuthenticated { dismiss() }
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Sign In")
                    }
                }
                .buttonStyle(AppButtonStyle())
                .disabled(email.isEmpty || password.count < 6)

                if let error = authService.errorMessage {
                    Text(error)
                        .font(AppTheme.captionFont)
                        .foregroundColor(.red)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Email Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
