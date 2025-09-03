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



// UserDefaults is a key-value storage system.
// UserDefaults will automatically be loaded when your app launches – if you store a lot in there your app launch will slow down. To give you at least an idea, you should aim to store no more than 512KB in there.
// Using UserDefaults takes iOS a little time to write your data to permanent storage. They don’t write updates immediately because you might make several changes back to back, so instead they wait some time then write out all the changes at once.
struct StoringUserDataUsingUserDefaults: View {
    @State private var tapCount = UserDefaults.standard.integer(forKey: "tapCount") // if the app is run for the first time and the key can’t be found, it just sends back 0.
    
    var body: some View {
        Button("Tap Count: \(tapCount)") {
            tapCount += 1
            UserDefaults.standard.set(tapCount, forKey: "tapCount")
            
            // We need to use UserDefaults.standard which is the built-in instance of UserDefaults that is attached to our app, but in more advanced apps you can create your own instances. For example, if you want to share defaults across several app extensions, you might create your own UserDefaults instance.
        }
    }
}

// SwiftUI can often wrap up UserDefaults inside a nice and simple property wrapper called @AppStorage (preferred)
struct StoringUserDataUsingAppStorage: View {
    @AppStorage("tapCount") private var tapCount = 0 // This works like @State: when the value changes, it will reinvoke the body property so our UI reflects the new data.
    // "tapCount" is the UserDefaults key where we want to store the data
    // providing a default value of 0 will be used if there is no existing value saved inside UserDefaults.
    
    var body: some View {
        Button("Tap Count: \(tapCount)") {
            tapCount += 1
        }
    }
}
// @AppStorage doesn’t make it easy to handle storing complex objects such as Swift structs – perhaps because Apple wants us to remember that storing lots of data in there is a bad idea!

// IMPORTANT: When it comes to you submitting an app to the App Store, Apple asks that you let them know why you're loading and saving data using UserDefaults. This also applies to the @AppStorage property wrapper. It's nothing to worry about, they just want to make sure developers aren't trying to identify users across apps.




// @AppStorage is great for storing simple settings such as integers and booleans, but when it comes to complex data – custom Swift types, for example – we need to poke around directly with UserDefaults itself, rather than going through the @AppStorage property wrapper.
// Since UserDefaults can’t directly store User, we use Codable + JSONEncoder
// We want to archive this custom type, so we can put it into UserDefaults, then unarchive it when it comes back out from UserDefaults.
// When working with a custom type that only has simple properties like strings, integers, booleans, arrays of strings, and so on – the only thing we need to do to support archiving and unarchiving is add a conformance to Codable
struct Student: Codable { // Codable is a protocol specifically for archiving and unarchiving data - “converting objects into plain text and back again.”
    let firstName: String
    let lastName: String
}


struct EncodingData: View {
    @State private var student = Student(firstName: "Purnaman", lastName: "Rai")
    
    var body: some View {
        Button("Save Student") {
            let jsonEncoder = JSONEncoder() // its job is to take something that conforms to Codable and send back that object in JavaScript Object Notation (JSON)
            jsonEncoder.outputFormatting = .prettyPrinted  // makes JSON readable
            
            if let jsonData = try? jsonEncoder.encode(student) {
                UserDefaults.standard.set(jsonData, forKey: "StudentData")
                
                print(String(data: jsonData, encoding: .utf8)!)
            }
            // the type of 'jsonData' is Data - designed to store any kind of data you can think of, such as strings, images, zip files, and more.
        }
        
        Button("Print Name") {
            if let savedStudent = UserDefaults.standard.data(forKey: "StudentData") {
                if let loadedUser = try? JSONDecoder().decode(Student.self, from: savedStudent) {
                    print(loadedUser.firstName)
                }
            }
        }
    }
}




// When we create static views in SwiftUI – when we hard-code a VStack, then a TextField, then a Button, and so on – SwiftUI can see exactly which views we have, and is able to control them, animate them, and more. But when we use List or ForEach to make dynamic views, SwiftUI needs to know how it can identify each item uniquely otherwise it will struggle to compare view hierarchies to figure out what has changed.
//struct Product: Identifiable // SOLUTION
struct Product {
//    let id = UUID() // SOLUTION
    let name: String
    let price: Double
}

struct IdentifiableDemo: View {
    @State private var products = [Product]()
    
    var body: some View {
        List {
            Button("Add Test Product") {
                products.append(Product(name: "Test", price: 3.99))
            }
            // AFTER SOLUTION: our products are now guaranteed to be identifiable uniquely, we no longer need to tell ForEach which property to use for the identifier – it knows there will be an 'id' property and that it will be unique, because that’s the point of the 'Identifiable' protocol.
//            ForEach(products) { product in // AFTER SOLUTION
            ForEach(products, id: \.name) { product in
                Text(product.name)
            }
            .onDelete { offsets in
                products.remove(atOffsets: offsets)
            }
        }
    }
}

// PROBLEM: Every time we create a test product we’re using the name “Test”, but we’ve also told SwiftUI that it can use the product name (\.name) as a unique identifier. So, when our code runs and we delete an item, SwiftUI looks at the array beforehand – “Test”, “Test”, “Test”, “Test” – then looks at the array afterwards – “Test”, “Test”, “Test” – and can’t easily tell what changed. Something has changed, because one item has disappeared, but SwiftUI can’t be sure which.

// In this situation we’re lucky, because List knows exactly which row we were swiping on, but in many other places that extra information won’t be available and our app will start to behave strangely.

// This is a logic error on our behalf: our code is fine, and it doesn’t crash at runtime, but we’ve applied the wrong logic to get to that end result – we’ve told SwiftUI that something will be a unique identifier, when it isn’t unique at all.

#Preview {
    IdentifiableDemo()
}
