//
//  ContentView.swift
//  iExpense
//
//  Created by Purnaman Rai (College) on 30/08/2025.
//

import SwiftUI

struct ExpenseItem: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expenses { // we can make this class load and save itself seamlessly later
    var items = [ExpenseItem]()
}

// now we have a struct to represent a single item of expense, and a class to store an array of all those items.

struct ContentView: View {
    @State private var expenses = Expenses()
    @State private var showingAddExpenseView = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(expenses.items) { item in
                    Text(item.name)
                }
                .onDelete(perform: removeItems)
            }
            .navigationTitle("iExpense")
            .toolbar {
                Button("Add Expense", systemImage: "plus") {
//                    expenses.items.append(ExpenseItem(name: "Test", type: "Personal", amount: 5.99))
                    showingAddExpenseView = true
                }
            }
            .sheet(isPresented: $showingAddExpenseView) {
                AddExpenseView(expenses: expenses)
            }
        }
    }
    
    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView()
}
