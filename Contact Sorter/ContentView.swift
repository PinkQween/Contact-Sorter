//
//  ContentView.swift
//  Contact Sorter
//
//  Created by Boone, Hanna - Student on 5/1/24.
//

import SwiftUI
import Contacts

struct ContentView: View {
    @State private var isShowingContactsAlert = false
    @State private var contacts: [CNContact] = []
    
    var body: some View {
        VStack {
            if (contacts.count > 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    List(contacts) {
                        Text($0.givenName)
                    }
                }
            } else {
                ProgressView()
                Color.white.ignoresSafeArea()
            }
        }
        .onAppear(perform: {
            fetchAllContacts()
        })
    }
    
    func fetchAllContacts() {
        DispatchQueue.global(qos: .background).async {
            let store = CNContactStore()
            
            // Check authorization status
            let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
            
            switch authorizationStatus {
            case .authorized:
                // Permission already granted, proceed with fetching contacts
                let keysToFetch = [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor]
                let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
                
                do {
                    try store.enumerateContacts(with: fetchRequest) { contact, _ in
                        self.contacts.append(contact)
                    }
                    DispatchQueue.main.async {
                        self.isShowingContactsAlert = true
                    }
                } catch {
                    print("Error fetching contacts: \(error)")
                }
                
            case .denied, .restricted:
                // Permission denied or restricted, handle gracefully
                print("Permission denied for contacts")
                
            case .notDetermined:
                // Request permission
                store.requestAccess(for: .contacts) { granted, error in
                    if granted {
                        // Permission granted, proceed with fetching contacts
                        self.fetchAllContacts()
                    } else {
                        // Permission denied, handle gracefully
                        print("Permission denied for contacts")
                    }
                }
            @unknown default:
                fatalError("Unhandled authorization status")
            }
        }
    }
}

#Preview {
    ContentView()
}
