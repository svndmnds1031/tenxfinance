//
//  WelcomeView.swift
//  tenxfinance
//
//  Created by Patricio Landeros on 29/04/26.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icono/Logo Temporal
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.primary.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "dollarsign.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.primary)
                }
                
                Text("tenxfinance")
                    .font(.system(size: 40, weight: .black, design: .rounded))
            }
            
            Text("Toma el control total de tu dinero con una experiencia minimalista.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: {
                authService.goToLogin()
            }) {
                Text("Comenzar")
                    .font(.headline)
                    .foregroundColor(Color(uiColor: .systemBackground))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primary)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
        }
    }
}
