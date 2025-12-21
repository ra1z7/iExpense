//
//  ContentView.swift
//  iExpense
//
//  Created by Purnaman Rai (College) on 30/08/2025.
//

import SwiftData
import SwiftUI

@Model
class Expense {
    var name: String
    var type: String
    var amount: Double
    
    init(name: String, type: String, amount: Double) {
        self.name = name
        self.type = type
        self.amount = amount
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var expenses: [Expense]
    
    var body: some View {
        NavigationStack {
            List {
                if expenses.count > 0 {
                    if expensesHasType("Personal") {
                        expenseListView(for: "Personal")
                    }
                    if expensesHasType("Business") {
                        expenseListView(for: "Business")
                    }
                } else {
                    ContentUnavailableView("No Expenses Yet", systemImage: "text.page.slash", description: Text("Press '+' to add new expenses."))
                }
            }
            .navigationTitle("iExpense")
            .toolbar {
                NavigationLink {
                    AddExpenseView()
                } label: {
                    Label("Add New Expense", systemImage: "plus")
                }
            }
        }
    }
    
    func expensesHasType(_ expenseType: String) -> Bool {
        for expense in expenses {
            if expense.type == expenseType {
                return true
            }
        }
        
        return false
    }
    
    func expenseListView(for expenseType: String) -> some View {
        Section(expenseType) {
            ForEach(expenses) { expense in
                if expense.type == expenseType {
                    HStack {
                        Text(expense.name)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(expense.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            .foregroundStyle(getColor(for: expense.amount))
                            .font(.body.bold())
                    }
                    .listRowBackground(getColor(for: expense.amount, asBackground: true))
                }
            }
            .onDelete(perform: removeItems)
        }
    }
    
    func removeItems(at offsets: IndexSet) {
        for index in offsets {
            let itemToDelete = expenses[index]
            modelContext.delete(itemToDelete)
        }
    }
    
    func getColor(for expenseAmount: Double, asBackground: Bool = false) -> Color {
        var color: Color
        
        if expenseAmount <= 100 {
            color = .blue
        } else if expenseAmount <= 1000 {
            color = .orange
        } else {
            color = .red
        }
        
        if asBackground {
            color = color.opacity(0.05)
        }
        
        return color
    }
}

#Preview {
    ContentView()
}
