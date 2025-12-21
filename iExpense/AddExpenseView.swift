//
//  AddExpenseView.swift
//  iExpense
//
//  Created by Purnaman Rai (College) on 04/09/2025.
//

import SwiftUI

struct AddExpenseView: View {
    @State private var expenseName = ""
    @State private var expenseType = "Personal"
    @State private var expenseAmount = 0.0
    
    @State private var stepMode = "Add"
    
    @Environment(\.modelContext) private var modelContext
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
                
                VStack {
                    Picker("Step Mode", selection: $stepMode) {
                        ForEach(["Add", "Subtract"], id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    HStack(spacing: 5) {
                        ForEach([1, 10, 100], id: \.self) { stepSize in
                            Button {
                                if stepMode == "Add" {
                                    expenseAmount += stepSize
                                } else {
                                    if expenseAmount >= stepSize {
                                        expenseAmount -= stepSize
                                    } else {
                                        expenseAmount = 0.0
                                    }
                                }
                            } label: {
                                Text("\(stepMode == "Add" ? "+" : "-")\(stepSize.formatted(.number.grouping(.never)))")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(stepMode == "Add" ? .blue : .red)
                            .buttonRepeatBehavior(.enabled)
                        }
                    }
                }
            }
            .navigationTitle("Add New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newExpense = Expense(name: expenseName, type: expenseType, amount: expenseAmount)
                        modelContext.insert(newExpense)
                        dismiss() // This causes the showingAddExpense Boolean in ContentView to go back to false
                    }
                    .disabled(expenseName == "New Expense" || expenseAmount <= 0)
                }
            }
        }
    }
}

#Preview {
    AddExpenseView()
}
