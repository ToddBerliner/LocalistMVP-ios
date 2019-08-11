//
//  ViewController.swift
//  Localist
//
//  Created by Todd Berliner on 10/11/18.
//  Copyright © 2018 Todd Berliner. All rights reserved.
//

import UIKit
import CoreLocation
import os

class ListsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LoginViewControllerDelegate {
    
    @IBOutlet weak var listTable: UITableView!
    var loginViewController: LoginViewController!
    
    private(set) var selectedList: List?
    var destinationListId: Int?
    
    @IBAction func actionButtonWasPressed(_ sender: Any) {
        logError(message: "does this work?", error: "{}")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        listTable.dataSource = self
        listTable.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getDataUpdate),
                                               name: NSNotification.Name(rawValue: dataModelDidUpdateNotification),
                                               object: nil)
        
        if !isLoggedIn() {
            performSegue(withIdentifier: TO_LOGIN, sender: nil)
        } else if destinationListId != nil {
            navigateToList(listId: destinationListId!)
        }
    }
    
    @objc func getDataUpdate() {
        // update UI on main thread
        DispatchQueue.main.async {
            // Updating whole table view
            self.listTable.reloadData()
        }
    }
    
    func isLoggedIn() -> Bool {
        let data = DataService.instance.getData()
        return data?.User != nil
    }
    
    func dismissLogin() {
        // Reload lists table
    }
    
    func handleLogin() {
        // let data = DataService.instance.getData()
        print("--- Logged in should sync data immediately")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataService.instance.getLists().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as? ListTableViewCell {
            let list = DataService.instance.getLists()[indexPath.row]
            cell.updateViews(list: list)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        } else {
            return ListTableViewCell()
        }
    }
    
    func navigateToList(listId: Int) {
        if let listIndex = DataService.instance.getListIndexByListId(listId: listId) {
            let indexPath = IndexPath(row: listIndex, section: 0)
            let list = DataService.instance.getLists()[listIndex]
            
            guard let listTable = listTable else {
                return
            }
            
            listTable.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            performSegue(withIdentifier: TO_LIST, sender: list)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = DataService.instance.getLists()[indexPath.row]
        performSegue(withIdentifier: TO_LIST, sender: list)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let list = DataService.instance.getLists()[indexPath.row]
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let deleteAlertController = UIAlertController(title: "Delete the list \(list.title)?", message: "It will be deleted for all members.", preferredStyle: .alert)
            
            // Create OK button
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action:UIAlertAction!) in
                
                // Code in this block will trigger when OK button tapped.
                DataService.instance.removeList(listRowIndex: indexPath.row)
                self.listTable.reloadData()
                
            }
            deleteAlertController.addAction(deleteAction)
            
            // Create Cancel button
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
                
            }
            deleteAlertController.addAction(cancelAction)
            
            // Present Dialog message
            self.present(deleteAlertController, animated: true, completion:nil)
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            self.selectedList = list
            self.performSegue(withIdentifier: TO_ADD_EDIT_LIST, sender: indexPath)
        }
        
        return [delete, edit]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let loginViewController = segue.destination as? LoginViewController {
            loginViewController.delegate = self
        }
        
        // If destination is within this NavigationController and is of type ListViewController,
        // initialize the ListViewContoller with the selected list
        if let listViewController = segue.destination as? ListViewController {
            // the row index is used to find the list in the data service
            let rowIndex = listTable.indexPathForSelectedRow!.row
            listViewController.initItems(list: (sender as? List)!, rowIndex: rowIndex)
        }
        
        // Check if the sender is a List, indicating that we're editing a list
        // and need to initialize the AddEditListViewController to edit mode. Tapping
        // a row marks items done; the only seque from a list is via the edit action
        if let indexPath = sender as? IndexPath {
            
            guard let addEditListNavigationController = segue.destination as? UINavigationController else {
                return
            }
            
            guard let addEditListViewController = addEditListNavigationController.topViewController as? AddEditListViewController else {
                return
            }
            
            if selectedList == nil {
                print("selected list is nil?")
                return
            }
            
            addEditListViewController.initList(list: selectedList!, listIndex: indexPath.row)
        }
    }
}

