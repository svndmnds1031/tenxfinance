//
//  DashboardView.swift
//  tenxfinance
//
//  Created by Patricio Landeros on 28/04/26.
//

import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject var authService: AuthService
    @Environment(\.colorScheme) private var colorScheme
    
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @State private var showingAddTransaction = false
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            dashboardTab
                .tabItem { Label("Resumen", systemImage: "house.fill") }
                .tag(0)

            SettingsView()
                .tabItem { Label("Ajustes", systemImage: "gearshape.fill") }
                .tag(1)
        }
        .accentColor(.primary)
    }
    
    // MARK: - Vistas Extraídas
    
    private var dashboardTab: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    mainScrollContent
                }
            }
            .navigationTitle("Resumen")
            .background(backgroundGradient)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddTransaction = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .onAppear {
                setupView()
                ensureDefaultCategoriesExist()
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
                    .modelContainer(modelContext.container) // Asegura que comparta la base de datos
            }
            .onChange(of: transactions) { _, newTransactions in
                viewModel.calculateTotals(transactions: newTransactions)
            }
            .onChange(of: viewModel.selectedFilter) { _, _ in
                viewModel.calculateTotals(transactions: transactions)
            }
        }
    }
    
    private var mainScrollContent: some View {
        VStack(spacing: 24) {
            balanceCard
            filterSection
           
            // Usamos el listado completo para garantizar la visualización inmediata en el resumen
            let filteredTransactions = viewModel.filteredTransactions(from: transactions)
            
            if !filteredTransactions.isEmpty {
                chartSection(for: filteredTransactions)
                recentTransactionsSection(for: filteredTransactions)
            } else {
                emptyStateView
            }
        }
        .padding()
        .padding(.bottom, 60)
    }
    
    private var backgroundGradient: some View {
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
    }
    
    private func setupView() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
         
        if let serifDescriptor = UIFont.systemFont(ofSize: 17, weight: .bold).fontDescriptor.withDesign(.serif) {
            appearance.titleTextAttributes = [.font: UIFont(descriptor: serifDescriptor, size: 18)]
            appearance.largeTitleTextAttributes = [.font: UIFont(descriptor: serifDescriptor, size: 34)]
        }
         
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
         
        viewModel.calculateTotals(transactions: transactions)
    }
    
    private func ensureDefaultCategoriesExist() {
        let descriptor = FetchDescriptor<Category>()
        do {
            let existing = try modelContext.fetch(descriptor)
            if existing.isEmpty {
                let defaults = [
                    Category(name: "Comida", colorHex: "#FF5733", iconName: "fork.knife", type: .expense),
                    Category(name: "Transporte", colorHex: "#33FF57", iconName: "car.fill", type: .expense),
                    Category(name: "Salario", colorHex: "#3357FF", iconName: "briefcase.fill", type: .income),
                    Category(name: "General", colorHex: "#888888", iconName: "cart", type: .expense)
                ]
                for cat in defaults {
                    modelContext.insert(cat)
                }
                try modelContext.save()
            }
        } catch {
            print("Error al inicializar categorías: \(error)")
        }
    }
    
    // MARK: - UI Components
    
    private var balanceCard: some View {
        VStack(spacing: 8) {
            Text("Balance Total")
                .font(.system(.subheadline, design: .serif))
                .foregroundColor(.secondary)
             
            Text(viewModel.formatCurrency(viewModel.totalBalance))
                .font(.system(size: 40, weight: .bold, design: .serif))
                .foregroundColor(viewModel.totalBalance >= 0 ? .primary : .red)
             
            HStack(spacing: 32) {
                StatView(title: "Ingresos", amount: viewModel.totalIncome, color: .green)
                StatView(title: "Gastos", amount: viewModel.totalExpense, color: .red)
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 10, y: 5)
    }
    
    private var filterSection: some View {
        Picker("Periodo", selection: $viewModel.selectedFilter) {
            ForEach(TimeFilter.allCases) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 4)
    }
    
    private func chartSection(for currentTransactions: [Transaction]) -> some View {
        VStack(alignment: .leading) {
            Text("Gastos vs Ingresos")
                .font(.system(.headline, design: .serif))
             
            Chart {
                RuleMark(y: .value("Cero", 0))
                    .foregroundStyle(.gray.opacity(0.3))
                 
                ForEach(currentTransactions) { transaction in
                    BarMark(
                        x: .value("Fecha", transaction.date, unit: .day),
                        y: .value("Monto", transaction.type == .income ? transaction.amount : -transaction.amount)
                    )
                    .foregroundStyle(transaction.type == .income ? Color.green.gradient : Color.red.gradient)
                    .cornerRadius(4)
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
        )
    }
    
    private func recentTransactionsSection(for currentTransactions: [Transaction]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transacciones Recientes")
                .font(.system(.headline, design: .serif))
             
            ForEach(currentTransactions.prefix(5)) { transaction in
                TransactionRowView(transaction: transaction)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No hay transacciones aún")
                .font(.system(.headline, design: .serif))
            Text("Toca el botón + para comenzar a registrar tus finanzas.")
                .font(.system(.subheadline, design: .serif))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }
}

// MARK: - Subcomponentes Reutilizables

struct StatView: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(.caption, design: .serif))
                .foregroundColor(.secondary)
            Text(amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .font(.system(.callout, design: .serif))
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: transaction.category?.iconName ?? "dollarsign")
                        .foregroundColor(.primary)
                )
             
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category?.name ?? transaction.type.rawValue)
                    .font(.system(.subheadline, design: .serif))
                    .fontWeight(.medium)
                 
                Text(transaction.date, style: .date)
                    .font(.system(.caption, design: .serif))
                    .foregroundColor(.secondary)
            }
             
            Spacer()
             
            Text(transaction.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .font(.system(.subheadline, design: .serif))
                .fontWeight(.semibold)
                .foregroundColor(transaction.type == .income ? .green : .primary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
        )
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthService())
}
