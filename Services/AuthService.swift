//
//  AuthService.swift
//  tenxfinance
//
//  Created by Patricio Landeros on 28/04/26.
//

import Foundation
import SwiftUI
import Combine
import LocalAuthentication

struct UserAccount: Codable, Identifiable, Equatable {
    var id = UUID()
    var username: String
    var passwordHash: String // En una app real se encripta, aquí lo guardamos simple para local
}

enum AppRoute {
    case welcome
    case login
    case register
    case mainApp
}

final class AuthService: ObservableObject {
    @Published var currentRoute: AppRoute = .welcome
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: UserAccount? = nil
    
    // Guardamos la lista de usuarios en formato JSON dentro de AppStorage
    @AppStorage("registeredUsersJSON") private var registeredUsersJSON: String = "[]"
    
    // Propiedad para saber si ya existe al menos una cuenta en el dispositivo
    var hasAccounts: Bool {
        return !getAllUsers().isEmpty
    }
    
    // MARK: - Manejo de la Lista de Usuarios
    
    func getAllUsers() -> [UserAccount] {
        guard let data = registeredUsersJSON.data(using: .utf8) else { return [] }
        do {
            let users = try JSONDecoder().decode([UserAccount].self, from: data)
            return users
        } catch {
            return []
        }
    }
    
    private func saveUsers(_ users: [UserAccount]) {
        do {
            let data = try JSONEncoder().encode(users)
            if let jsonString = String(data: data, encoding: .utf8) {
                registeredUsersJSON = jsonString
            }
        } catch {
            print("Error al guardar usuarios")
        }
    }
    
    // MARK: - Navegación
    
    func goToLogin() {
        withAnimation(.spring()) { currentRoute = .login }
    }
    
    func goToRegister() {
        withAnimation(.spring()) { currentRoute = .register }
    }
    
    func goToWelcome() {
        withAnimation(.spring()) { currentRoute = .welcome }
    }
    
    // MARK: - Registro de Nuevo Usuario
    
    @MainActor
    func register(username: String, password: String) async throws {
        let cleanUser = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPass = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanUser.isEmpty, !cleanPass.isEmpty else {
            throw NSError(domain: "Auth", code: 400, userInfo: [NSLocalizedDescriptionKey: "Completa todos los campos"])
        }
        
        var users = getAllUsers()
        
        // Verificamos si el usuario ya existe
        if users.contains(where: { $0.username.lowercased() == cleanUser.lowercased() }) {
            throw NSError(domain: "Auth", code: 409, userInfo: [NSLocalizedDescriptionKey: "El nombre de usuario ya está registrado"])
        }
        
        // Creamos y agregamos el nuevo usuario
        let newUser = UserAccount(username: cleanUser, passwordHash: cleanPass)
        users.append(newUser)
        saveUsers(users)
        
        // Lo dejamos autenticado automáticamente
        self.currentUser = newUser
        self.isAuthenticated = true
        withAnimation(.easeInOut(duration: 0.5)) {
            currentRoute = .mainApp
        }
    }
    
    // MARK: - Login Estricto
    
    @MainActor
    func login(username: String, password: String) async throws {
        let cleanUser = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPass = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let users = getAllUsers()
        
        // Buscamos coincidencia exacta de usuario y contraseña
        guard let foundUser = users.first(where: { $0.username == cleanUser && $0.passwordHash == cleanPass }) else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Usuario o contraseña incorrectos"])
        }
        
        self.currentUser = foundUser
        self.isAuthenticated = true
        withAnimation(.easeInOut(duration: 0.5)) {
            currentRoute = .mainApp
        }
    }
    
    func logout() {
        self.isAuthenticated = false
        self.currentUser = nil
        withAnimation(.easeInOut) {
            currentRoute = hasAccounts ? .login : .welcome
        }
    }
}
