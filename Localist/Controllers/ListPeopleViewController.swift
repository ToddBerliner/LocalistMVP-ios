//
//  ListPeopleViewController.swift
//  LocalistMVP
//
//  Created by Todd Berliner on 3/1/19.
//  Copyright © 2019 Todd Berliner. All rights reserved.
//

import UIKit

class ListPeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddEditPeopleViewControllerDelegate {
    
    @IBOutlet weak var membersTable: UITableView!
    
    weak var parentDelegate: ListLocationsViewControllerDelegate!

    var members = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        membersTable.delegate = self
        membersTable.dataSource = self
    }
    
    func setMembers(members: [Person]) {
        self.members = members
        membersTable.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         // cell is controlled by identifier
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell") as? PersonTableViewCell {

            var totalRows = members.count + 1
            totalRows -= 1 // to adjust for 0 indexed indexPath.row
            
            if indexPath.row == totalRows {
                // last row of "Add People"
                cell.updateViews(nameText: nil, avatarName: nil, isLast: true)
            } else {
                let person = members[indexPath.row]
                if let you = DataService.instance.getUser(), you.id == person.id {
                    cell.updateViews(nameText: "You", avatarName: person.image_name, isLast: false)
                } else {
                    cell.updateViews(nameText: person.name, avatarName: person.image_name, isLast: false)
                }
                
            }

            cell.selectionStyle = UITableViewCell.SelectionStyle.none

            return cell
        } else {
            return PersonTableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == members.count {
            self.parent?.performSegue(withIdentifier: TO_ADD_EDIT_PEOPLE, sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "List Members"
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var tableViewActions = [UITableViewRowAction]()
        if indexPath.row != 0 && indexPath.row != members.count {
            let removeMember = UITableViewRowAction(style: .destructive, title: "Remove", handler: {action, indexPath in
                self.members.remove(at: indexPath.row)
                tableView.reloadData()
                self.parentDelegate.updateSegmentControls()
            })
            tableViewActions.append(removeMember)
        }
        return tableViewActions
    }
    
}

protocol ListPeopleViewControllerDelegate {
    func updateSegmentControls()
}
