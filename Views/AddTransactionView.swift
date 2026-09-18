//
//  AddTransactionView.swift
//  tenxfinance
//
//  Created by Patricio Landeros on 28/04/26.
//

import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var categories: [Category]
    
    @State private var amount: Double?
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategory: Category?
    @State private var date = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Tipo", selection: $selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Categoría") {
                    let filteredCategories = categories.filter { $0.type == selectedType }
                    
                    if filteredCategories.isEmpty {
                        Text("No hay categorías. Se asignará una por defecto.")
                            .font(.system(.caption, design: .serif))
                            .foregroundColor(.secondary)
                    } else {
                        Picker("Categoría", selection: $selectedCategory) {
                            Text("Seleccionar...").tag(nil as Category?)
                            ForEach(filteredCategories) { category in
                                HStack {
                                    Image(systemName: category.iconName)
                                    Text(category.name)
                                }.tag(category as Category?)
                            }
                        }
                    }
                }
                
                Section("Detalles") {
                    TextField("Monto", value: $amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .keyboardType(.decimalPad)
                        .font(.title2)
                    
                    DatePicker("Fecha", selection: $date, displayedComponents: [.date])
                    
                    TextField("Notas (Opcional)", text: $notes)
                }
            }
            .navigationTitle("Nueva Transacción")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveTransaction()
                    }
                    .disabled(amount == nil || amount == 0)
                }
            }
            .onChange(of: selectedType) { _, _ in
                selectedCategory = nil
            }
            .onAppear {
                checkAndCreateDefaultCategoriesIfNeeded()
            }
        }
    }
    
    private func checkAndCreateDefaultCategoriesIfNeeded() {
        if categories.isEmpty {
            let defaults = [
                Category(name: "Comida", colorHex: "#FF5733", iconName: "fork.knife", type: .expense),
                Category(name: "Transporte", colorHex: "#33FF57", iconName: "car.fill", type: .expense),
                Category(name: "Salario", colorHex: "#3357FF", iconName: "briefcase.fill", type: .income),
                Category(name: "General", colorHex: "#888888", iconName: "cart", type: .expense)
            ]
            for cat in defaults {
                modelContext.insert(cat)
            }
            try? modelContext.save()
        }
    }
    
    private func saveTransaction() {
        guard let validAmount = amount else { return }
        
        var targetCategory: Category? = selectedCategory
        
        // Si no seleccionó ninguna, buscamos una existente que coincida con el tipo
        if targetCategory == nil {
            for cat in categories {
                if cat.type == selectedType {
                    targetCategory = cat
                    break
                }
            }
        }
        
        // Red de seguridad absoluta: si sigue sin haber categoría, creamos una de emergencia
        if targetCategory == nil {
            let fallbackCategory = Category(
                name: selectedType == .income ? "Ingreso General" : "Gasto General",
                colorHex: "#000000",
                iconName: selectedType == .income ? "arrow.down.circle" : "arrow.up.circle",
                type: selectedType
            )
            modelContext.insert(fallbackCategory)
            targetCategory = fallbackCategory
        }
        
        let newTransaction = Transaction(
            amount: validAmount,
            date: date,
            notes: notes,
            type: selectedType,
            category: targetCategory
        )
        
        modelContext.insert(newTransaction)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error al guardar la transacción en SwiftData: \(error)")
        }
    }
}
