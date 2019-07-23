//
//  ListLocationsViewController.swift
//  LocalistMVP
//
//  Created by Todd Berliner on 3/1/19.
//  Copyright © 2019 Todd Berliner. All rights reserved.
//

import UIKit
import MapKit

class ListLocationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddEditLocationsTableViewControllerDelegate {
    
    @IBOutlet weak var locationsTable: UITableView!
    
    var locations = [Location]()

    override func viewDidLoad() {
        super.viewDidLoad()

        locationsTable.delegate = self
        locationsTable.dataSource = self
    }
    
    weak var parentDelegate: ListLocationsViewControllerDelegate!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RetailLocationCell") as? RetailLocationTableViewCell {
            var totalRows = locations.count
            totalRows = totalRows - 1 // translate to 0 based index for indexPath.row
            totalRows = totalRows + 1 // add Add Retailer row

            if indexPath.row == totalRows {
                cell.updateViews(location: nil, isLast: true)
            } else {
                let location = locations[indexPath.row]
                cell.updateViews(location: location, isLast: false)
            }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        } else {
            return RetailLocationTableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var tableViewActions = [UITableViewRowAction]()
        if indexPath.row < locations.count {
            let removeLocation = UITableViewRowAction(style: .destructive, title: "Remove", handler: {action, indexPath in
                self.locations.remove(at: indexPath.row)
                tableView.reloadData()
                self.parentDelegate.updateSegmentControls()
            })
            tableViewActions.append(removeLocation)
        }
        return tableViewActions
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == locations.count {
            self.parent?.performSegue(withIdentifier: TO_ADD_EDIT_RETAILERS, sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Retail Locations"
    }
    
    func addRetailLocation(location: Location) {
        
        // Add location to existing or new retailer
        let found = locations.contains(where: {existingLocation in
            return existingLocation.identifier == location.identifier
        })
        if !found {
            locations.append(location)
            locationsTable.reloadData()
            parentDelegate?.updateSegmentControls()
        }
    }
    
    func removeRetailLocation(location: Location) {
        locations = locations.filter({existingLocation in
            return existingLocation.identifier != location.identifier
        })
        locationsTable.reloadData()
        parentDelegate?.updateSegmentControls()
    }
    
    func addLocation(location: MKMapItem) {

        let retailLocation = extractRetailLocationFromLocation(location: location)
        addRetailLocation(location: retailLocation)
    }
    
    func removeLocation(location: MKMapItem) {
        let retailLocation = extractRetailLocationFromLocation(location: location)
        removeRetailLocation(location: retailLocation)
    }

}

protocol ListLocationsViewControllerDelegate: NSObjectProtocol {
    func updateSegmentControls()
}
