//
//  ContentView.swift
//  iExpense
//
//  Created by Purnaman Rai (College) on 30/08/2025.
//

import SwiftUI

struct ExpenseItem: Codable, Identifiable {
    // Swift already includes Codable conformances for the UUID, String, and Double, so it’s able to make ExpenseItem conform automatically as soon as we ask for it.
    var id = UUID() // However, you will see a warning that 'id' will not be decoded because we made it a constant and assigned a default value. This is actually the behavior we want, but Swift is trying to be helpful because it’s possible you did plan to decode this value from JSON. Fix: make it variable.
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expenses { // we can make this class load and save itself seamlessly later
    var items: [ExpenseItem] {
        didSet {
            if let encodedData = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encodedData, forKey: "Items")
            }
        }
    }
    
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) { // if we had just used [ExpenseItem], Swift would want to know what we meant – are we trying to make a copy of the class? Were we planning to reference a static property or method? Did we perhaps mean to create an instance of the class? To avoid confusion – to say that we mean we’re referring to the type itself, known as the type object – we write .self after it.
                items = decodedItems
                return
            }
        }
        
        items = []
    }
}
// now we have a struct to represent a single item of expense, and a class to store an array of all those items.

struct ContentView: View {
    @State private var expenses = Expenses()
    
    var body: some View {
        NavigationStack {
            List {
                if expenses.items.count > 0 {
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
                    AddExpenseView(expenses: expenses)
                } label: {
                    Label("Add New Expense", systemImage: "plus")
                }
            }
        }
    }
    
    func expensesHasType(_ expenseType: String) -> Bool {
        for expense in expenses.items {
            if expense.type == expenseType {
                return true
            }
        }
        
        return false
    }
    
    func expenseListView(for expenseType: String) -> some View {
        Section(expenseType) {
            ForEach(expenses.items) { expense in
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
        expenses.items.remove(atOffsets: offsets)
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
