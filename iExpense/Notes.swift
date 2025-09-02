//
//  Notes.swift
//  iExpense
//
//  Created by Purnaman Rai (College) on 30/08/2025.
//

import Observation
// Now that we've imported the framework @Observable comes from, if you right-click on @Observable in your code, you can choose 'Expand Macro' to see exactly what rewriting is happening – Xcode will show you all the hidden code that's being generated.
import SwiftUI

// SwiftUI’s @State property wrapper is designed for simple data that is local to the current view, but as soon as you want to share data you need to take some important extra steps.

@Observable // is a macro, which is Swift's way of quietly rewriting our code to add extra functionality.
class User {
    var firstName = "Bilbo"
    var lastName = "Baggins"
}

// 1. Our two properties are marked @ObservationTracked, which means Swift and SwiftUI are watching them for changes.
// 2. If you right-click on @ObservationTracked you can expand that macro too – yes, it's a macro inside a macro. This macro has the job of tracking whenever any property is read or written, so that SwiftUI can update only views that absolutely need to be refreshed. SwiftUI remembers: “this view depends on that property.” Later, if user.firstName changes, SwiftUI knows exactly which views to refresh → it doesn’t need to reload everything.
// 3. Our class is made to conform to the Observable protocol. This is important, because some parts of SwiftUI look for this to mean "this class can be watched for changes."

struct UsingStateWithClass: View {
    @State private var user = User()
    // Behind the scenes (When User is a struct), each time a value inside our struct changes, the whole struct changes
    
    // However, when User is a class, the 'user' property itself isn’t changing, but it’s still pointing to the exact same User object so, @State doesn’t notice anything and can’t reload the view.
    
    // To fix it, we must use @Observable before class which tells SwiftUI: “Don’t just watch the property. Also track the internal changes of this object. Reload any view that relies on a property when it changes.”

    var body: some View {
        Text("Your name is \(user.firstName) \(user.lastName).")

        TextField("First name", text: $user.firstName)
        TextField("Last name", text: $user.lastName)
    }
}

// When working with structs, the @State property wrapper keeps a value alive and also watches it for changes.
// On the other hand, when working with classes, @State is just there for keeping object alive – all the watching for changes and updating the view is taken care of by @Observable.




// Sheets work much like alerts, in that we don’t present them directly with code such as mySheet.present() or similar. Instead, we define the conditions under which a sheet should be shown, and when those conditions become true or false the sheet will either be presented or dismissed respectively.
struct SecondView: View {
    @Environment(\.dismiss) var dismiss
    // @Environment is a property wrapper, which allows a view to read values provided by the system or parent views. Think of it like a “shared bag of values” passed down the view hierarchy (things like color scheme, locale, dismiss action, etc.)
    // \.dismiss is a key path to the system-provided “dismiss action”. This action tells SwiftUI how to dismiss the current view if it was presented modally (e.g., using .sheet, .fullScreenCover, or a navigation stack). So, we’re effectively saying “hey, figure out how my view was presented, then dismiss it appropriately.”
    // SwiftUI automatically fills the 'dismiss' property with the correct value from the environment. The type of dismiss is actually DismissAction (a special type provided by SwiftUI).
    
    let userName: String
    
    var body: some View {
        Text("Hello, \(userName)")
        
        Button("Dismiss") {
            dismiss()
        }
    }
}

struct ShowingHidingViewsWithSheet: View {
    @State private var showingSheet = false
    
    var body: some View {
        Button("Show Sheet") {
            showingSheet = true
        }
        .sheet(isPresented: $showingSheet) {
            SecondView(userName: "@ra1z")
        }
    }
}




struct DeleteItemsFromList: View {
    @State private var allNumbers = [Int]()
    @State private var currentNumber = 1
    
    var body: some View {
        NavigationStack {
            List {
                Button("Add Number") {
                    allNumbers.append(currentNumber)
                    currentNumber += 1
                }
                
                ForEach(allNumbers, id: \.self) {
                    Text("Row \($0)")
                }
                .onDelete { offsets in
                    allNumbers.remove(atOffsets: offsets)
                }
                
                // In order to make onDelete() work, we need to implement a method that will receive a single parameter of type IndexSet. This is a bit like a set of integers, except it’s sorted, and it’s just telling us the positions of all the items in the ForEach that should be removed.
            }
            .toolbar {
                EditButton()
            }
        }
    }
}

#Preview {
    DeleteItemsFromList()
}
