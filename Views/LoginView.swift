//
//  LoginView.swift
//  tenxfinance
//
//  Created by Patricio Landeros on 29/04/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    
    @State private var showAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Identifícate")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Accede a tu panel financiero.")
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
            }
            
            Button(action: {
                Task {
                    isLoading = true
                    do {
                        try await authService.login(username: username, password: password)
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
                        Text("Entrar")
                            .fontWeight(.bold)
                    }
                }
                .foregroundColor(Color(uiColor: .systemBackground))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primary)
                .cornerRadius(16)
            }
            
            // Enlace directo para crear un nuevo usuario si no tiene cuenta o quiere registrar otra
            Button("¿No tienes cuenta? Regístrate aquí") {
                authService.goToRegister()
            }
            .foregroundColor(.secondary)
            
            Button("Cancelar") {
                authService.goToWelcome()
            }
            .foregroundColor(.secondary)
            .font(.subheadline)
            
            Spacer()
        }
        .padding(30)
        .alert("Aviso de seguridad", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}
