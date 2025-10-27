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
    
    var body: some View {
        
            
            VStack(spacing: 20) {
                Text("Create Account").font(.largeTitle.bold())
                
                    
                
                InputField(icon: "preson.crop.circle", placeholder: "name", text: $name)
                InputField(icon: "envelope", placeholder: "Email", text: $email)
                InputField(icon: "lock", placeholder: "Password", text: $password, isSecure: true)
                
                Button(action: {
                    focusedField = nil
                    Task { await authVM.signUp(name: name, email: email, password: password, context: context) }
                }) {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                    Button(action: {dismiss()}) {
                        Text("Log In")
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
