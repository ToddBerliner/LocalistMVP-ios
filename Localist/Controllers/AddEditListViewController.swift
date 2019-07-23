//
//  AddEditListViewController.swift
//  Localist
//
//  Created by Todd Berliner on 1/4/19.
//  Copyright © 2019 Todd Berliner. All rights reserved.
//

import UIKit
import MapKit

class AddEditListViewController: UIViewController, UITextFieldDelegate, ListLocationsViewControllerDelegate, ListPeopleViewControllerDelegate  {
    
    @IBOutlet weak var listNameField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentContainer: UIView!
    
    private(set) var editingListIndex: Int?
    private(set) var listTitle: String = ""
    private(set) var members = [Person]()
    private(set) var retailers = [Retailer]()
    
    var listPeopleViewController: ListPeopleViewController!
    var listLocationsViewController: ListLocationsViewController!
    
    override func viewWillAppear(_ animated: Bool) {
        let peopleCount = listPeopleViewController.members.count
        let locationsCount = listLocationsViewController.locations.count
        segmentedControl.setTitle("People (\(peopleCount))", forSegmentAt: 0)
        segmentedControl.setTitle("Locations (\(locationsCount))", forSegmentAt: 1)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // List Title
        listNameField.delegate = self
        if listTitle != "" {
            listNameField.text = listTitle
        }
        
        self.listLocationsViewController = {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ListLocationsViewController") as! ListLocationsViewController
            
                    self.addViewControllerAsChildViewController(childViewController: viewController)
            
                    return viewController
                    // https://www.youtube.com/watch?v=kq-lHR5ZOW0
                }()
        
        self.listPeopleViewController = {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ListPeopleViewController") as! ListPeopleViewController
            
                    self.addViewControllerAsChildViewController(childViewController: viewController)
            
                    return viewController
                    // https://www.youtube.com/watch?v=kq-lHR5ZOW0
                }()
        
        setupChildView()
        setMembers()
        setLocationsFromRetailers()
        listLocationsViewController.parentDelegate = self
        listPeopleViewController.parentDelegate = self
        
    }
    
    // TODO: enable done button
    // if loading existing list, enable when sufficient change made
    // if creating new, enable when people and retailers and name

    @IBAction func DoneWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupChildView() {
        setupSegmentedControl()
        updateChildView()
    }
    
    private func updateChildView() {
        listPeopleViewController.view.isHidden = !(segmentedControl.selectedSegmentIndex == 0)
        listLocationsViewController.view.isHidden = (segmentedControl.selectedSegmentIndex == 0)
    }
    
    private func addViewControllerAsChildViewController(childViewController: UIViewController) {
        addChild(childViewController)
        segmentContainer.addSubview(childViewController.view)
        childViewController.view.frame = segmentContainer.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childViewController.didMove(toParent: self)
    }
    
    func updateSegmentControls() {
        let peopleCount = listPeopleViewController.members.count + 1
        let locationsCount = listLocationsViewController.locations.count
        segmentedControl.setTitle("People (\(peopleCount))", forSegmentAt: 0)
        segmentedControl.setTitle("Locations (\(locationsCount))", forSegmentAt: 1)
    }
    
    private func setupSegmentedControl() {
        let peopleCount = members.count + 1
        let locationsCount = listLocationsViewController.locations.count
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "People (\(peopleCount))", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Locations (\(locationsCount))", at: 1, animated: false)
        segmentedControl.addTarget(self, action: #selector(selectionDidChange(sender:)), for: .valueChanged)
    
        segmentedControl.selectedSegmentIndex = 0
    }
    
    @objc func selectionDidChange(sender: UISegmentedControl) {
        updateChildView()
    }
    
    func initList(list: List, listIndex: Int) {
        
        navigationItem.rightBarButtonItem?.title = "Done"
        navigationItem.title = "Edit List"
        editingListIndex = listIndex
        listTitle = list.title
        members = list.members
        retailers = list.retailers
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        listNameField.resignFirstResponder()
        
        if (segue.identifier == TO_ADD_EDIT_PEOPLE) {
            let addEditPeopleViewController = segue.destination as! AddEditPeopleViewController
            addEditPeopleViewController.delegate = listPeopleViewController as AddEditPeopleViewControllerDelegate
            addEditPeopleViewController.existingMembers = listPeopleViewController.members
        }
        
        if (segue.identifier == TO_ADD_EDIT_RETAILERS) {
            let searchResultTableViewController = segue.destination as! AddEditLocationsTableViewController
            searchResultTableViewController.searchDelegate = listLocationsViewController as AddEditLocationsTableViewControllerDelegate
            searchResultTableViewController.existingLocations = listLocationsViewController.locations
        }
    }
    
    func setRetailersFromLocations() {
        
        // Clear existing locations and reset
        for (index, _) in retailers.enumerated() {
            retailers[index].clearLocations()
        }
        
        for location in listLocationsViewController.locations {
            var found = false
            // Loop retailers and update existing or create new below
            for (index, retailer) in retailers.enumerated() {
                // Check for existing location, else add location
                if retailer.name == location.name {
                    var locationFound = false
                    for (_, existingLocation) in retailer.locations.enumerated() {
                        if existingLocation.identifier == location.identifier {
                            locationFound = true
                        }
                    }
                    if !locationFound {
                        retailers[index].addLocation(location: location)
                    }
                    
                    found = true
                    break
                }
            }
            if !found {
                retailers.append(Retailer(name: location.name, imageName: "", selectedLocations: [location]))
            }
        }
    }
    
    func setLocationsFromRetailers() {
        for retailer in retailers {
            for location in retailer.locations {
                listLocationsViewController.locations.append(location)
            }
        }
    }
    
    func setMembers() {
        if editingListIndex == nil, let you = DataService.instance.getUser() {
            members.append(you)
        }
        listPeopleViewController.members = members
    }
    
    @IBAction func createWasPressed(_ sender: Any) {
        
        // Unique names
    
        self.setRetailersFromLocations()
        
        if editingListIndex == nil {
            
            // Creating a new list
            if listNameField.text == "" // || retailers.count == 0
            {
                let alert = UIAlertController(title: "Details, Please 😎", message: "The List Name and locations are required.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let newList = List(title: listNameField.text!, items: [], retailers: retailers, members: listPeopleViewController.members)
            DataService.instance.addList(list: newList)
        } else {
            // Editing an existing list
            DataService.instance.updateList(listRowIndex: editingListIndex!, title: listNameField.text!, members: listPeopleViewController.members, retailers: retailers)
        }
        dismiss(animated: true, completion: nil)
    }
}
