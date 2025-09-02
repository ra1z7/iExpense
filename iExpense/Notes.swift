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

#Preview {
    UsingStateWithClass()
}
