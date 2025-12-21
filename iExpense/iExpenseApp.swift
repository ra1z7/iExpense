//
//  iExpenseApp.swift
//  iExpense
//
//  Created by Purnaman Rai (College) on 30/08/2025.
//

import SwiftData
import SwiftUI

@main
struct iExpenseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Expense.self)
    }
}
