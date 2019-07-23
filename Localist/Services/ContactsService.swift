//
//  ContactsService.swift
//  LocalistMVP
//
//  Created by Todd Berliner on 5/4/19.
//  Copyright © 2019 Todd Berliner. All rights reserved.
//

import Foundation
import Contacts

class ContactsService {
    
    var contacts: [CNContact] = []

    let store = CNContactStore()
    let keysToFetch = [CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactFamilyNameKey, CNContactThumbnailImageDataKey, CNContactImageDataKey, CNContactFormatter.descriptorForRequiredKeys(for: .fullName)] as! [CNKeyDescriptor]
    
    var delegate: ContactsServiceDelegate?
    
    func syncContacts() {
        
        // this func is async because of the network call, so it should call a delegate to handle
        // the results when ready
        
        let url = URL(string: GET_SERVER_PEOPLE_URL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
            if let error = error {
                logError(message: "Error in syncContacts", error: error.localizedDescription)
                print("error: \(error)")
                return
            }
            guard let data = data else {
                return
            }
            do {
                //Decode retrived data with JSONDecoder and assing type of Article object
                let serverPeople = try JSONDecoder().decode(PeopleFromServer.self, from: data)
                let contacts = self.getContacts(serverPeople: serverPeople.people)
                // Compare and potentially store
                let existingContacts = DataService.instance.getPeople()
                if (!self.peopleListsMatch(lhsPeople: contacts, rhsPeople: existingContacts)) {
                    // Set in new list of people
                    DataService.instance.setPeople(people: contacts)
                    // Update data
                    ArchiveService.instance.archiveData()
                }
                
                DispatchQueue.main.async {
                    self.delegate?.handleContactsUpdated()
                }
            } catch let jsonError {
                logError(message: "Error in syncContacs for jsonError", error: jsonError.localizedDescription)
                print(jsonError)
            }
            
        }).resume()
    }
    
    func findContactByNumber(number: String) -> Person? {
        let numberDigits = number.filter{("0"..."9").contains($0)}
        let phoneNumber = CNPhoneNumber.init(stringValue: numberDigits)
        let phoneNumberPredicate = CNContact.predicateForContacts(matching: phoneNumber)
        do {
            let matches = try store.unifiedContacts(matching: phoneNumberPredicate, keysToFetch: keysToFetch)
            if matches.count > 0 {
                let contact = matches[0]
                let fullName = CNContactFormatter.string(from: contact, style: .fullName)
                return Person(name: fullName ?? contact.givenName, first_name: contact.givenName, imageName: "Contact", phone: numberDigits)
            }
        } catch let error {
            logError(message: "Error in findContactByNumber", error: error.localizedDescription)
            print (error)
            return nil
        }
        return nil
    }
    
    func printContacts() {
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        do {
            try store.enumerateContacts(with: request) { (contact, stop) in
                print(contact)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getContacts(serverPeople: [Person]) -> [Person] {
        guard let me = DataService.instance.getData()?.User else {
            return []
        }
        var people: [Person] = []
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        do {
            try store.enumerateContacts(with: request) { (contact, stop) in
                for contactPhoneNumber: CNLabeledValue in contact.phoneNumbers {
                    var contactNumber = contactPhoneNumber.value.stringValue.filter{("0"..."9").contains($0)}
                    contactNumber = String(contactNumber.suffix(10))
                    for serverPerson in serverPeople {
                        if contactNumber == serverPerson.phone {
                            // use the name in the contact list since it's the name the user has
                            // chosen for the contact - person.id is id from server
                            let unifiedPerson = Person(id: serverPerson.id, name: serverPerson.name, first_name: serverPerson.first_name, imageName: "Contact", phone: contactNumber)
                            if (serverPerson.id == me.id) {
                                people.insert(unifiedPerson, at: 0)
                            } else {
                                people.append(unifiedPerson)
                            }
                        }
                    }
                }
            }
        } catch {
            logError(message: "Error in getContacts", error: error.localizedDescription)
            print(error.localizedDescription)
        }
        
        return people
    }
    
    func peopleListsMatch(lhsPeople: [Person], rhsPeople: [Person]) -> Bool {
        var lhsIds = [Int]()
        var rhsIds = [Int]()
        for person in lhsPeople {
            guard let id = person.id else {
                continue
            }
            lhsIds.append(id)
        }
        for person in rhsPeople {
            guard let id = person.id else {
                continue
            }
            rhsIds.append(id)
        }
        
        if lhsIds.count != rhsIds.count {
            return false
        }
        lhsIds.sort()
        rhsIds.sort()
        return lhsIds == rhsIds
    }
}

protocol ContactsServiceDelegate {
    func handleContactsUpdated()
}
