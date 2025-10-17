//
//  LoginView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/13/25.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    
    @FocusState private var focusedField: Field?

    enum Field {
        case email, password
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
                        Task { await authVM.signIn(email: email, password: password) }
                    }) {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    
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
