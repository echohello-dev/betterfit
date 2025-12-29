import AuthenticationServices
import BetterFit
import CryptoKit
import SwiftUI

/// Sign In View with Apple, Google, Email/Password, and Guest Mode
struct SignInView: View {
    let theme: AppTheme
    let onSignIn: (String, String) async throws -> Void  // Apple: idToken, nonce
    let onEmailSignIn: (String, String) async throws -> Void  // Email/Password: email, password
    let onGuestMode: () -> Void

    @State private var currentNonce: String?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showEmailSignIn = false
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false

    var body: some View {
        ZStack {
            theme.backgroundGradient.ignoresSafeArea()

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
        .preferredColorScheme(theme.preferredColorScheme)
    }

    // MARK: - Main Sign In Content

    private var mainSignInContent: some View {
        VStack(spacing: 32) {
            Spacer()

            // MARK: - Logo & Title

            VStack(spacing: 16) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(theme.accent)

                Text("BetterFit")
                    .bfHeading(theme: theme, size: 44, relativeTo: .largeTitle)
                    .foregroundStyle(theme.accent)

                Text("Your strength training coach")
                    .font(.title3)
                    .foregroundStyle(.secondary)
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
                .cornerRadius(12)
                .disabled(isLoading)

                // Google Sign In Button
                Button {
                    Task {
                        isLoading = true
                        defer { isLoading = false }
                        do {
                            // In a real app, you'd handle the OAuth redirect
                            // For now, show email sign-in as fallback
                            showEmailSignIn = true
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "g.circle.fill")
                        Text("Sign in with Google")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white.opacity(0.15))
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }
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
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white.opacity(0.15))
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }
                .disabled(isLoading)

                // Guest Mode Button
                Button {
                    onGuestMode()
                } label: {
                    HStack {
                        Image(systemName: "person.fill.questionmark")
                        Text("Continue as Guest")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white.opacity(0.1))
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }
                .disabled(isLoading)

                // Error message
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            // MARK: - Privacy note

            Text("We value your privacy. Guest mode stores data locally only.")
                .font(.caption)
                .foregroundStyle(.secondary)
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
                        .foregroundStyle(.secondary)

                    TextField("your@email.com", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(12)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                }

                // Password Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    SecureField("Password", text: $password)
                        .textContentType(isSignUp ? .newPassword : .password)
                        .padding(12)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                }

                if isSignUp {
                    Text("Minimum 6 characters")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                // Sign In / Sign Up Button
                Button {
                    handleEmailSignIn()
                } label: {
                    Text(isSignUp ? "Create Account" : "Sign In")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(theme.accent)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                .disabled(email.isEmpty || password.isEmpty || isLoading)

                // Toggle Sign Up / Sign In
                HStack {
                    Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                        .font(.caption)
                        .foregroundStyle(.secondary)

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
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    // MARK: - Handlers

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
        onGuestMode: {
            print("Continue as guest")
        }
    )
}
