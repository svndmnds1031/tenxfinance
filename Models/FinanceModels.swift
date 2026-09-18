import Foundation
import SwiftData

public enum TransactionType: String, Codable, CaseIterable {
    case income = "Ingreso"
    case expense = "Gasto"
}

@Model
final class Transaction {
    var id: UUID = UUID()
    var amount: Double = 0.0
    var date: Date = Date()
    var notes: String = ""
    var typeRawValue: String = TransactionType.expense.rawValue
    
    @Relationship(deleteRule: .nullify)
    var category: Category?
    
    var type: TransactionType {
        get { TransactionType(rawValue: typeRawValue) ?? .expense }
        set { typeRawValue = newValue.rawValue }
    }
    
    init(id: UUID = UUID(), amount: Double, date: Date = Date(), notes: String = "", type: TransactionType, category: Category? = nil) {
        self.id = id
        self.amount = amount
        self.date = date
        self.notes = notes
        self.typeRawValue = type.rawValue
        self.category = category
    }
}

@Model
final class Category {
    var id: UUID = UUID()
    var name: String = ""
    var colorHex: String = "#000000"
    var iconName: String = "cart"
    var typeRaw: String = TransactionType.expense.rawValue
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.category)
    var transactions: [Transaction]? = []

    var type: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .expense }
        set { typeRaw = newValue.rawValue }
    }

    init(id: UUID = UUID(), name: String, colorHex: String = "#000000", iconName: String = "cart", type: TransactionType = .expense) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName
        self.typeRaw = type.rawValue
    }
}
