//
//  RegisterView.swift
//  tenxfinance
//
//  Created by Patricio Landeros on 29/04/26.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authService: AuthService
    
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    
    @State private var showAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Crear Cuenta")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Registra tus credenciales locales en tenxfinance.")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 40)
            
            VStack(spacing: 20) {
                TextField("Nombre de usuario", text: $username)
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                
                SecureField("Contraseña", text: $password)
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                
                SecureField("Confirmar contraseña", text: $confirmPassword)
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
            }
            
            Button(action: {
                guard password == confirmPassword else {
                    errorMessage = "Las contraseñas no coinciden"
                    showAlert = true
                    return
                }
                
                Task {
                    isLoading = true
                    do {
                        try await authService.register(username: username, password: password)
                    } catch {
                        errorMessage = error.localizedDescription
                        showAlert = true
                    }
                    isLoading = false
                }
            }) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Registrarse y Entrar")
                            .fontWeight(.bold)
                    }
                }
                .foregroundColor(Color(uiColor: .systemBackground))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primary)
                .cornerRadius(16)
            }
            
            // Botón para volver al Login si ya tiene cuenta
            Button("¿Ya tienes cuenta? Inicia sesión") {
                authService.goToLogin()
            }
            .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(30)
        .alert("Aviso", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}
