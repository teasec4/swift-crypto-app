//
//  SignUpView.swift
//  CryptoAsyncAwait
//
//  Created by Максим Ковалев on 10/13/25.
//
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    
    @FocusState private var focusedField: Field?

    enum Field {
        case name, email, password
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty &&
        email.contains("@") &&
        password.count >= 6
    }
    
    var body: some View {
        
            
            VStack(spacing: 20) {
                Text("Create Account").font(.largeTitle.bold())
                
                    
                
                InputField(icon: "person.crop.circle", placeholder: "Name", text: $name)
                InputField(icon: "envelope", placeholder: "Email", text: $email)
                InputField(icon: "lock", placeholder: "Password (min 6)", text: $password, isSecure: true)
                
                Button(action: {
                    focusedField = nil
                    Task { await authVM.signUp(name: name, email: email, password: password, context: context) }
                }) {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .disabled(!isFormValid || authVM.isLoading)
                
                HStack(spacing: 4) {
                    Text("Already have an account?")
                    Button(action: {dismiss()}) {
                        Text("Log In").bold()
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
            .contentLoading(isVisible: $authVM.isLoading)
        .padding()
    }
    
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
