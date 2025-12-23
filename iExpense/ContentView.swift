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
    @State private var sortOrder = [SortDescriptor(\Expense.amount), SortDescriptor(\Expense.name)]
    @State private var filterBy = "All"
    
    let filterOptions = ["All", "Personal", "Business"]
    
    var body: some View {
        NavigationStack {
            List {
                if expenses.count > 0 {
                    if expensesHasType("Personal") {
                        ExpenseListView(for: "Personal", sortOrder: sortOrder, filterBy: filterBy)
                    }
                    if expensesHasType("Business") {
                        ExpenseListView(for: "Business", sortOrder: sortOrder, filterBy: filterBy)
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
                
                Menu("Sort & Filter", systemImage: "arrow.up.arrow.down") {
                    Picker("Sort", selection: $sortOrder) {
                        Text("Sort By Amount")
                            .tag([
                                SortDescriptor(\Expense.amount),
                                SortDescriptor(\Expense.name)
                            ])
                        
                        Text("Sort By Name")
                            .tag([
                                SortDescriptor(\Expense.name),
                                SortDescriptor(\Expense.amount)
                            ])
                    }
                    
                    Picker("Filter", selection: $filterBy) {
                        ForEach(filterOptions, id: \.self) {
                            Text("Filter By \($0)")
                                .tag($0)
                        }
                    }
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
}

#Preview {
    ContentView()
}
