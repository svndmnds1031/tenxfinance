//
//  SettingsView.swift
//  tenxfinance
//
//  Created by Patricio Landeros on 29/04/26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.colorScheme) private var colorScheme
    
    @AppStorage("selectedCurrency") private var selectedCurrency: String = "USD"
    @AppStorage("selectedAppearance") private var selectedAppearance: String = "system"
    @State private var showingAccountManager = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Tarjeta de Usuario Activo
                    if let currentUser = authService.currentUser {
                        VStack(spacing: 12) {
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(Color.primary.opacity(0.06))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.title3)
                                            .foregroundColor(.primary)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("CUENTA ACTIVA")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                        .tracking(1.2)
                                    
                                    Text(currentUser.username)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                                Spacer()
                            }
                            
                            Divider()
                                .opacity(0.5)
                            
                            Button(action: { showingAccountManager = true }) {
                                HStack {
                                    Image(systemName: "person.2.circle")
                                    Text("Gestionar cuentas locales")
                                        .font(.subheadline)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .foregroundColor(.primary)
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(20)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                        )
                    }
                    
                    // Tarjeta de Preferencias (Moneda y Apariencia)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("PREFERENCIAS")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .tracking(1.2)
                            .padding(.leading, 4)
                        
                        VStack(spacing: 14) {
                            HStack {
                                Text("Moneda Base")
                                    .font(.subheadline)
                                Spacer()
                                Picker("", selection: $selectedCurrency) {
                                    Text("USD ($)").tag("USD")
                                    Text("EUR (€)").tag("EUR")
                                    Text("MXN ($)").tag("MXN")
                                    Text("GBP (£)").tag("GBP")
                                }
                                .pickerStyle(.menu)
                            }
                            
                            Divider()
                                .opacity(0.5)
                            
                            HStack {
                                Text("Apariencia")
                                    .font(.subheadline)
                                Spacer()
                                Picker("", selection: $selectedAppearance) {
                                    Text("Sistema").tag("system")
                                    Text("Claro").tag("light")
                                    Text("Oscuro").tag("dark")
                                }
                                .pickerStyle(.menu)
                            }
                        }
                        .padding(20)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                        )
                    }
                    
                    // Tarjeta de Zona de Sesión y App Info
                    VStack(spacing: 14) {
                        Button(role: .destructive) {
                            authService.logout()
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Cerrar Sesión")
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            .foregroundColor(.red)
                        }
                        
                        Divider()
                            .opacity(0.5)
                        
                        HStack {
                            Text("Versión tenxfinance")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("1.0.0")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(20)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                    )
                    
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Ajustes")
                        .font(.headline)
                        .tracking(0.5)
                }
            }
            .background(
                LinearGradient(
                    colors: colorScheme == .dark ? [
                        Color(UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)),
                        Color(UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1.0))
                    ] : [
                        Color(UIColor(red: 0.98, green: 0.98, blue: 0.97, alpha: 1.0)),
                        Color(UIColor(red: 0.94, green: 0.93, blue: 0.91, alpha: 1.0))
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .sheet(isPresented: $showingAccountManager) {
                AccountsManagerView()
            }
        }
        .preferredColorScheme(resolvedColorScheme)
    }
    
    var resolvedColorScheme: ColorScheme? {
        switch selectedAppearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}

// MARK: - Subvista para Administrar Múltiples Cuentas Locales
struct AccountsManagerView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Cuentas guardadas en este dispositivo")) {
                    ForEach(authService.getAllUsers()) { user in
                        HStack {
                            Image(systemName: "person.circle")
                                .font(.title2)
                            Text(user.username)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            if authService.currentUser?.id == user.id {
                                Text("Activa")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Gestor de Cuentas")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthService())
}
