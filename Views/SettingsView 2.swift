//
//  SettingsView 2.swift
//  tenxfinance
//
//  Created by Patricio Landeros on 06/08/26.
//


//
//  SettingsView.swift
//  tenxfinance
//
//  Created by Patricio Landeros on 29/04/26.
//

import SwiftUI

struct SettingsView: View {
    // Inyectamos el AuthService para poder ejecutar la función de cerrar sesión y obtener datos del usuario
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationStack {
            List {
                // Sección de Cuenta y Seguridad
                Section(header: Text("Cuenta")) {
                    // Muestra el usuario actual si está disponible en la sesión
                    if let currentUser = authService.currentUser {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(Color.primary.opacity(0.1))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.primary)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Usuario conectado")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(currentUser.username)
                                    .font(.headline)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // Botón de Cerrar Sesión
                    Button(role: .destructive) {
                        authService.logout()
                    } {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Cerrar Sesión")
                                .fontWeight(.medium)
                        }
                    }
                }
                
                // Sección de Información de la App
                Section(header: Text("Acerca de")) {
                    HStack {
                        Text("Aplicación")
                        Spacer()
                        Text("tenxfinance")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Versión")
                        Spacer()
                        Text("1.0.0 (Local)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Ajustes")
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
}
