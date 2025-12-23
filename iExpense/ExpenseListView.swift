//
//  ExpenseListView.swift
//  iExpense
//
//  Created by Purnaman Rai (College) on 22/12/2025.
//

import SwiftData
import SwiftUI

struct ExpenseListView: View {
    let expenseType: String
    
    @Environment(\.modelContext) private var modelContext
    @Query private var expenses: [Expense]
    
    var body: some View {
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
    
    func removeItems(at offsets: IndexSet) {
        for index in offsets {
            let itemToDelete = expenses[index]
            modelContext.delete(itemToDelete)
        }
    }
    
    init(for expenseType: String, sortOrder: [SortDescriptor<Expense>], filterBy: String) {
        self.expenseType = expenseType
        _expenses = Query(
            filter: #Predicate<Expense> { expense in
                if filterBy == "All" {
                    return true
                } else if filterBy == expense.type {
                    return true
                } else {
                    return false
                }
            },
            sort: sortOrder
        )
    }
}

#Preview {
    ExpenseListView(for: "Personal", sortOrder: [SortDescriptor(\Expense.name)], filterBy: "All")
}
