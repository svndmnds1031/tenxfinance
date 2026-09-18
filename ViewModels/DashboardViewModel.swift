//
//  DashboardViewModel.swift
//  tenxfinance
//
//  Created by Patricio Landeros on 28/04/26.
//

import Foundation
import SwiftUI
import Combine

enum TimeFilter: String, CaseIterable, Identifiable {
    case all = "Todo"
    case month = "Este Mes"
    case week = "Esta Semana"
    
    var id: String { self.rawValue }
}

final class DashboardViewModel: ObservableObject {
    @Published var totalBalance: Double = 0.0
    @Published var totalIncome: Double = 0.0
    @Published var totalExpense: Double = 0.0
    @Published var selectedFilter: TimeFilter = .all
    
    func calculateTotals(transactions: [Transaction]) {
        let filteredTransactions = filteredTransactions(from: transactions)
        
        let incomes = filteredTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let expenses = filteredTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        
        DispatchQueue.main.async {
            self.totalIncome = incomes
            self.totalExpense = expenses
            self.totalBalance = incomes - expenses
        }
    }
    
    func filteredTransactions(from transactions: [Transaction]) -> [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedFilter {
        case .all:
            return transactions
        case .month:
            return transactions.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
        case .week:
            return transactions.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .weekOfYear) }
        }
    }
    
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}
