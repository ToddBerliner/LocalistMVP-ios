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
    private(set) public var markedItems = [Item]()
    // selectedRowIndex is bad news - poor way to find the desired list in the data
    private(set) public var selectedRowIndex: Int = 0
    private(set) public var showHiddenItems: Bool = false
    
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
        // TODO: handle sections - translate itemIndex correctly
        if let markButton = (sender as? MarkItemButton) {
            let indexPath = markButton.indexPath
            let item = getItem(indexPath: indexPath)
            if item.marked != nil {
                DataService.instance.restoreItemToList(itemIndex: indexPath.row, listRowIndex: selectedRowIndex)
            } else {
                DataService.instance.removeItemFromList(itemIndex: indexPath.row, listRowIndex: selectedRowIndex)
            }
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if (itemField.isEditing) {
            itemField.resignFirstResponder()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return items.count
        } else {
            return markedItems.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Check mode - showHidden: true || false
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Completed Items"
        }
        return nil
    }
    
    func getItem(indexPath: IndexPath) -> Item {
        if (indexPath.section == 0) {
            return items[indexPath.row]
        } else {
            return markedItems[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = getItem(indexPath: indexPath)
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as? ItemTableViewCell {
            cell.updateViews(item: item, indexPath: indexPath)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        } else {
            return ItemTableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get the item at the index path and populate the itemField
        // TODO: handle sections - translate itemIndex correctly
        let selectedItem = items[indexPath.row]
        if (selectedItem.marked == nil) {
            itemField.text = selectedItem.title
            itemField.becomeFirstResponder()
        }
    }
    
    func initItems(list: List, rowIndex: Int) {
        let user = DataService.instance.getUser()!
        items = list.items
        markedItems = list.markedItems
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
