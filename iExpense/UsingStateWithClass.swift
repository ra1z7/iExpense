//
//  Notes.swift
//  iExpense
//
//  Created by Purnaman Rai (College) on 30/08/2025.
//

import SwiftUI

// SwiftUI’s @State property wrapper is designed for simple data that is local to the current view, but as soon as you want to share data you need to take some important extra steps.

//@Observable
class User {
    var firstName = "Bilbo"
    var lastName = "Baggins"
}

struct UsingStateWithClass: View {
    @State private var user = User()
    // Behind the scenes, each time a value inside our struct changes, the whole struct changes
    
    // Remember how we had to use the 'mutating' keyword for struct methods that modify properties? This is because if we create the struct’s properties as variable but the struct itself is constant, we can’t change the properties – Swift needs to be able to destroy and recreate the whole struct when a property changes, and that isn’t possible for constant structs. Classes don’t need the mutating keyword, because even if the class instance is marked as constant Swift can still modify variable properties.
    
    // So, when User is a class, the instance itself isn’t changing, so @State doesn’t notice anything and can’t reload the view.
    
    // To fix it, we must use @Observable before class

    var body: some View {
        Text("Your name is \(user.firstName) \(user.lastName).")

        TextField("First name", text: $user.firstName)
        TextField("Last name", text: $user.lastName)
    }
}

#Preview {
    UsingStateWithClass()
}
