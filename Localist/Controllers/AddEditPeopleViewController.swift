//
//  AddPeopleViewController.swift
//  Localist
//
//  Created by Todd Berliner on 1/4/19.
//  Copyright © 2019 Todd Berliner. All rights reserved.
//

import UIKit
import Contacts

class AddEditPeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ContactsServiceDelegate {
    
    weak var delegate: AddEditPeopleViewControllerDelegate?
    
    var contactsService = ContactsService()
    
    private(set) var people = [Person]()
    var existingMembers = [Person]()
    var you: Person? = nil
    
    
    @IBOutlet weak var peopleTable: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshContol = UIRefreshControl()
        refreshContol.addTarget(self, action: #selector(AddEditPeopleViewController.handleRefresh(_:)), for: .valueChanged)
        return refreshContol
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        you = DataService.instance.getUser()
        people = DataService.instance.getPeople()
        if people.count == 0, you != nil {
            if existingMembers.count == 0 {
                people.append(you!)
            } else {
                people = existingMembers
            }
        }
        peopleTable.delegate = self
        peopleTable.dataSource = self
        peopleTable.addSubview(refreshControl)
        contactsService.delegate = self
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        // this kicks off the syncContacts method
        contactsService.syncContacts()
    }
    
    func handleContactsUpdated() {
        people = DataService.instance.getPeople()
        self.peopleTable.reloadData()
        refreshControl.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Add & Remove People"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SelectablePersonCell") as? SelectablePersonTableViewCell {
            
            let person = people[indexPath.row]
            
            if you != nil, (person.id == you!.id) {
                cell.updateViews(nameText: "You", avatarName: person.image_name)
            } else {
                cell.updateViews(nameText: person.name, avatarName: person.image_name)
            }
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            let isSelected = existingMembers.contains(where: { element in
                return element.id == person.id
            })
            if isSelected {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
            return cell
        } else {
            return SelectablePersonTableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if delegate != nil {
            delegate?.setMembers(members: getSelectedPeople())
        }
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        let person = people[indexPath.row]
        if you != nil, person.id == you!.id {
            return nil
        } else {
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if delegate != nil {
            delegate?.setMembers(members: getSelectedPeople())
        }
    }
    
    func getSelectedPeople() -> [Person] {
        var selectedPeople = [Person]()
        if let selectedRows = peopleTable.indexPathsForSelectedRows {
            for selectedRow in selectedRows {
                selectedPeople.append(people[selectedRow.row])
            }
        }
        return selectedPeople
    }
}

protocol AddEditPeopleViewControllerDelegate: NSObjectProtocol {
    func setMembers(members: [Person])
}
