//
//  ContentView.swift
//  Contact Sorter
//
//  Created by Boone, Hanna - Student on 5/1/24.
//

import Contacts
import SwiftUI
import os

class ContactStore: ObservableObject {
    @Published var contacts: [CNContact] = []
    @Published var error: Error? = nil

    func fetch() {
        os_log("Fetching contacts")
        do {
            let store = CNContactStore()
            let keysToFetch = [CNContactGivenNameKey as CNKeyDescriptor,
                               CNContactMiddleNameKey as CNKeyDescriptor,
                               CNContactFamilyNameKey as CNKeyDescriptor,
                               CNContactImageDataAvailableKey as CNKeyDescriptor,
                               CNContactImageDataKey as CNKeyDescriptor]
            os_log("Fetching contacts: now")
            let containerId = store.defaultContainerIdentifier()
            let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            os_log("Fetching contacts: succesfull with count = %d", contacts.count)
            self.contacts = contacts
        } catch {
            os_log("Fetching contacts: failed with %@", error.localizedDescription)
            self.error = error
        }
    }
}

extension CNContact {
    var name: String {
        return [givenName, middleName, familyName].filter{ $0.count > 0}.joined(separator: " ")
    }
}

struct ContactsView: View {
    @EnvironmentObject var store: ContactStore

    var body: some View {
        VStack{
            if store.error == nil {
                VStack {
                    HStack {
                        Image(systemName: "plus")
                            .foregroundStyle(.clear)
                            .padding()
                        
                        Spacer()
                        
                        Text("Contacts")
                            .font(.title)
                        
                        Spacer()
                        
                        Image(systemName: "plus")
                            .foregroundStyle(Color.accentColor)
                            .padding()
                            .font(.title)
                    }
                    
                    Divider()
                }
                
                List(store.contacts) { (contact: CNContact) in
                    return Text(contact.name)
                }.onAppear{
                    DispatchQueue.main.async {
                        self.store.fetch()
                    }
                }
            } else {
                Text("error: \(store.error!.localizedDescription)")
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        ContactsView().environmentObject(ContactStore())
    }
}

#Preview {
    ContentView()
}
