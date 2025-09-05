//
//  AddExpenseView.swift
//  iExpense
//
//  Created by Purnaman Rai (College) on 04/09/2025.
//

import SwiftUI

struct AddExpenseView: View {
    var expenses: Expenses
    
    @State private var expenseName = ""
    @State private var expenseType = "Personal"
    @State private var expenseAmount = 0.0
    
    @Environment(\.dismiss) var dismiss // We don't need to specify its type, because we have used @Environment property wrapper
    
    let expenseTypes = ["Personal", "Business"]
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $expenseName)
                
                Picker("Type", selection: $expenseType) {
                    ForEach(expenseTypes, id: \.self) {
                        Text($0)
                    }
                }
                
                TextField("Amount", value: $expenseAmount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Add New Expense")
            .toolbar {
                Button("Save") {
                    expenses.items.append(ExpenseItem(name: expenseName, type: expenseType, amount: expenseAmount))
                    dismiss() // This causes the showingAddExpense Boolean in ContentView to go back to false
                }
            }
        }
    }
}

#Preview {
    AddExpenseView(expenses: Expenses())
}
