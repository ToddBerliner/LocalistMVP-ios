//
//  ListsViewController.swift
//  Localist
//
//  Created by Todd Berliner on 10/24/18.
//  Copyright © 2018 Todd Berliner. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var itemTable: UITableView!
    @IBOutlet weak var inputRow: UIView!
    @IBOutlet weak var itemField: UITextField!
    
    private(set) public var items = [Item]()
    // selectedRowIndex is bad news - poor way to find the desired list in the data
    private(set) public var selectedRowIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemTable.dataSource = self
        itemTable.delegate = self
        itemField.delegate = self
        let addBtn = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60))
        addBtn.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        addBtn.setTitle("Add Item", for: .normal)
        addBtn.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        addBtn.addTarget(self, action: #selector(ListViewController.handleItemDidFinishEditing), for: .touchUpInside)
        
        itemField.inputAccessoryView = addBtn
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getDataUpdate),
                                               name: NSNotification.Name(rawValue: dataModelDidUpdateNotification),
                                               object: nil)
    }
    
    @IBAction func addItemPressed(_ sender: Any) {
        DataService.instance.addItemToList(item: Item(title: "Foot"), listRowIndex: 1)
    }
    @IBAction func removeItemPressed(_ sender: Any) {
        print("remove item pressed")
        DataService.instance.removeItemFromList(itemIndex: 0, listRowIndex: 1)
    }
    @objc func getDataUpdate() {
        // update UI on main thread
        DispatchQueue.main.async {
            // Updating whole table view
            let lists = DataService.instance.getLists(), list = lists[self.selectedRowIndex]
            self.initItems(list: list, rowIndex: self.selectedRowIndex)
            self.itemTable.reloadData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        handleItemDidFinishEditing()
        return true
    }
    
    @IBAction func markItemButtonPressed(_ sender: Any) {
        if let markButton = (sender as? MarkItemButton) {
            let itemIndex = markButton.itemIndex
            DataService.instance.removeItemFromList(itemIndex: itemIndex, listRowIndex: selectedRowIndex)
        }
    }
    
    @objc func handleItemDidFinishEditing() {
        if let itemText = itemField.text {
            
            // check for input - add item if good input
            if itemText != "" {
                if (itemTable.indexPathForSelectedRow != nil) {
                    let selectedItemIndexPath = itemTable.indexPathForSelectedRow
                    DataService.instance.editItemInList(itemText: itemText, itemIndex: selectedItemIndexPath!.row, listRowIndex: selectedRowIndex)
                } else {
                    let newItem = Item(title: itemText)
                    DataService.instance.addItemToList(item: newItem, listRowIndex: selectedRowIndex)
                }
            }
            // clear out itemText
            itemField.text = ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as? ItemTableViewCell {
            cell.updateViews(item: items[indexPath.row], itemIndex: indexPath.row)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        } else {
            return ItemTableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get the item at the index path and populate the itemField
        let selectedItem = items[indexPath.row]
        itemField.text = selectedItem.title
        itemField.becomeFirstResponder()
    }
    
    func initItems(list: List, rowIndex: Int) {
        let user = DataService.instance.getUser()!
        items = list.items
        selectedRowIndex = rowIndex
        navigationItem.title = list.title
        let otherMembers = list.members.filter({member in
            return member.id != user.id
        })
        if (otherMembers.count > 0) {
            var prompt = "Shared with "
            switch otherMembers.count {
            case 1:
                prompt += otherMembers[0].first_name
            case 2:
                prompt += "\(otherMembers[0].first_name) and \(otherMembers[1].first_name )"
            default:
                for (index, member) in otherMembers.enumerated() {
                    if index == 0 {
                        prompt += member.first_name
                    } else if index == list.members.count - 1 {
                        prompt += ", and \(member.first_name)"
                    } else {
                        prompt += ", \(member.first_name)"
                    }
                }
            }
            navigationItem.prompt = prompt
        }
    }
    
}
