//
//  LoginView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/13/25.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.modelContext) private var context
    @State private var email = ""
    @State private var password = ""
    
    @FocusState private var focusedField: Field?

    enum Field {
        case email, password
    }
    
    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty &&
        email.contains("@")
    }
    
    var body: some View {
        NavigationStack {
                VStack(spacing: 20) {
                    Text("Welcome Back")
                        .font(.largeTitle.bold())
                    
                    InputField(icon: "envelope", placeholder: "Email", text: $email)
                    InputField(icon: "lock", placeholder: "Password", text: $password, isSecure: true)
                    
                    Button(action: {
                        focusedField = nil
                        Task { await authVM.signIn(email: email, password: password, context: context) }
                    }) {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .disabled(!isFormValid || authVM.isLoading)
                    
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                        NavigationLink(destination: SignUpView()) {
                            Text("Sign Up").bold()
                        }
                    }
                    .font(.footnote)
                    .padding(.top, 8)
                    
                    if let error = authVM.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, 6)
                    }
                    
                    
                }
                
                .padding()

        }
        .contentLoading(isVisible: $authVM.isLoading)
    }
    
}


#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
