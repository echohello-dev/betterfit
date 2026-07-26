import AuthenticationServices
import BetterFit
import CryptoKit
import SwiftUI

/// Sign In View with Apple, Google, Email/Password, and Guest Mode
struct SignInView: View {
    let theme: AppTheme
    let onSignIn: (String, String) async throws -> Void  // Apple: idToken, nonce
    let onEmailSignIn: (String, String) async throws -> Void  // Email/Password: email, password
    let onGoogleSignIn: () async throws -> Void  // Google OAuth
    let onGuestMode: () -> Void
    var onDismiss: (() -> Void)?  // Optional dismiss callback for sheet presentation

    @State private var currentNonce: String?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showEmailSignIn = false
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            BFColors.background(for: colorScheme).ignoresSafeArea()

            if showEmailSignIn {
                emailSignInContent
            } else {
                mainSignInContent
            }

            // Loading overlay
            if isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                ProgressView()
                    .tint(theme.accent)
                    .scaleEffect(1.5)
            }
        }
    }

    // MARK: - Main Sign In Content

    private var mainSignInContent: some View {
        VStack(spacing: 32) {
            // Close button when dismissible
            if let onDismiss {
                HStack {
                    Spacer()
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                    }
                    .disabled(isLoading)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }

            Spacer()

            // MARK: - Logo & Title

                VStack(spacing: 16) {
                FitnessIcon(systemImage: "figure.strengthtraining.traditional", size: 80, color: theme.accent)

                Text("BetterFit")
                    .bfHeading(theme: theme, size: 44, relativeTo: .largeTitle)
                    .foregroundStyle(theme.accent)

                Text("Your strength training coach")
                    .font(.title3)
                    .foregroundStyle(BFColors.textSecondary(for: colorScheme))
            }

            Spacer()

            // MARK: - Sign In Options

            VStack(spacing: 16) {
                // Apple Sign In Button
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        let nonce = randomNonceString()
                        currentNonce = nonce
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = sha256(nonce)
                    },
                    onCompletion: { result in
                        handleSignInWithAppleResult(result)
                    }
                )
                .signInWithAppleButtonStyle(.white)
                .frame(height: 50)
                .cornerRadius(BFRadius.medium)
                .disabled(isLoading)

                // Google Sign In Button
                Button {
                    handleGoogleSignIn()
                } label: {
                    HStack {
                        Image(systemName: "g.circle.fill")
                        Text("Sign in with Google")
                    }
                }
                .buttonStyle(.bfSecondary)
                .disabled(isLoading)

                // Email & Password Button
                Button {
                    showEmailSignIn = true
                    isSignUp = false
                    email = ""
                    password = ""
                    errorMessage = nil
                } label: {
                    HStack {
                        Image(systemName: "envelope.fill")
                        Text("Sign in with Email")
                    }
                }
                .buttonStyle(.bfSecondary)
                .disabled(isLoading)

                // Guest Mode Button
                Button {
                    onGuestMode()
                } label: {
                    HStack {
                        Image(systemName: "person.fill.questionmark")
                        Text("Continue as Guest")
                    }
                }
                .buttonStyle(.bfSecondary)
                .disabled(isLoading)

                // Error message
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(BFColors.danger)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            // MARK: - Privacy note

            Text("We value your privacy. Guest mode stores data locally only.")
                .font(.caption)
                .foregroundStyle(BFColors.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
        }
    }

    // MARK: - Email Sign In Content

    private var emailSignInContent: some View {
        VStack(spacing: 24) {
            // Back Button
            HStack {
                Button {
                    showEmailSignIn = false
                    email = ""
                    password = ""
                    errorMessage = nil
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundStyle(theme.accent)
                }

                Spacer()

                Text(isSignUp ? "Create Account" : "Sign In")
                    .bfHeading(theme: theme, size: 18, relativeTo: .headline)
                    .foregroundStyle(theme.accent)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Spacer()

            // Form
            VStack(spacing: 16) {
                // Email Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.caption)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))

                    TextField("your@email.com", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: BFRadius.medium, style: .continuous)
                                .fill(BFColors.surfaceRaised(for: colorScheme))
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: BFRadius.medium, style: .continuous)
                                .stroke(BFColors.border(for: colorScheme), lineWidth: 1)
                        }
                }

                // Password Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.caption)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))

                    SecureField("Password", text: $password)
                        .textContentType(isSignUp ? .newPassword : .password)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: BFRadius.medium, style: .continuous)
                                .fill(BFColors.surfaceRaised(for: colorScheme))
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: BFRadius.medium, style: .continuous)
                                .stroke(BFColors.border(for: colorScheme), lineWidth: 1)
                        }
                }

                if isSignUp {
                    Text("Minimum 6 characters")
                        .font(.caption2)
                        .foregroundStyle(BFColors.textTertiary(for: colorScheme))
                }

                // Sign In / Sign Up Button
                Button {
                    handleEmailSignIn()
                } label: {
                    Text(isSignUp ? "Create Account" : "Sign In")
                }
                .buttonStyle(.bfPrimary)
                .disabled(email.isEmpty || password.isEmpty || isLoading)

                // Toggle Sign Up / Sign In
                HStack {
                    Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                        .font(.caption)
                        .foregroundStyle(BFColors.textSecondary(for: colorScheme))

                    Button {
                        isSignUp.toggle()
                        errorMessage = nil
                    } label: {
                        Text(isSignUp ? "Sign In" : "Create Account")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(theme.accent)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)

                // Error message
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(BFColors.danger)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    // MARK: - Handlers

    private func handleGoogleSignIn() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await onGoogleSignIn()
                isLoading = false
                // OAuth flow will open in browser and redirect back via betterfit:// URL
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Google sign in failed: \(error.localizedDescription)"
                }
            }
        }
    }

    private func handleSignInWithAppleResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard
                let appleIDCredential = authorization.credential
                    as? ASAuthorizationAppleIDCredential,
                let identityToken = appleIDCredential.identityToken,
                let tokenString = String(data: identityToken, encoding: .utf8),
                let nonce = currentNonce
            else {
                errorMessage = "Unable to fetch identity token or nonce"
                return
            }

            isLoading = true
            errorMessage = nil

            Task {
                do {
                    try await onSignIn(tokenString, nonce)
                    isLoading = false
                } catch {
                    await MainActor.run {
                        isLoading = false
                        errorMessage = "Sign in failed: \(error.localizedDescription)"
                    }
                }
            }

        case .failure(let error):
            let authError = error as? ASAuthorizationError
            if authError?.code != .canceled {
                errorMessage = "Sign in failed: \(error.localizedDescription)"
            }
        }
    }

    private func handleEmailSignIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password"
            return
        }

        guard email.contains("@") else {
            errorMessage = "Please enter a valid email"
            return
        }

        if isSignUp && password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await onEmailSignIn(email, password)
                isLoading = false
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Authentication failed: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: - Nonce Generation

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

// MARK: - Preview

#Preview {
    SignInView(
        theme: .bold,
        onSignIn: { token, nonce in
            print("Sign in with Apple: \(token)")
            try await Task.sleep(for: .seconds(1))
        },
        onEmailSignIn: { email, password in
            print("Sign in with email: \(email)")
            try await Task.sleep(for: .seconds(1))
        },
        onGoogleSignIn: {
            print("Sign in with Google")
            try await Task.sleep(for: .seconds(1))
        },
        onGuestMode: {
            print("Continue as guest")
        }
    )
}
