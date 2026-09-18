//
//  tenxfinanceApp.swift
//  tenxfinance
//
//  Created by Patricio Landeros...
//

import SwiftUI
import SwiftData

@main
struct tenxfinanceApp: App {
    @StateObject private var authService = AuthService()
    
    // Leemos la preferencia de apariencia guardada en UserDefaults
    @AppStorage("selectedAppearance") private var selectedAppearance: String = "system"

    var body: some Scene {
        WindowGroup {
            Group {
                switch authService.currentRoute {
                case .welcome:
                    WelcomeView()
                case .register:
                    RegisterView()
                case .login:
                    LoginView()
                case .mainApp:
                    DashboardView()
                }
            }
            .environmentObject(authService)
            // Aplicamos el esquema de color globalmente a toda la app según la elección
            .preferredColorScheme(
                selectedAppearance == "light" ? .light :
                selectedAppearance == "dark" ? .dark : nil
            )
        }
        .modelContainer(for: [Transaction.self, Category.self])
    }
}
