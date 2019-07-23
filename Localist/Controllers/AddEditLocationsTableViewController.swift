/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Primary view controller used to display search results.
*/

import UIKit
import CoreLocation
import MapKit

class AddEditLocationsTableViewController: UITableViewController {
    
    private enum SegueID: String {
        case showDetail
        case showAll
    }
    
    private enum CellReuseID: String {
        case resultCell
    }
    
    private var places: [MKMapItem]? {
        didSet {
            tableView.reloadData()
        }
    }
    var existingLocations = [Location]()
    
    weak var searchDelegate: AddEditLocationsTableViewControllerDelegate?
    
    private var suggestionController: SuggestionsTableTableViewController!
    private var searchController: UISearchController!

    @IBOutlet private var locationManager: LocationManager!
    
    private var locationManagerObserver: NSKeyValueObservation?
    
    private var foregroundRestorationObserver: NSObjectProtocol?
    
    private var localSearch: MKLocalSearch? {
        willSet {
            // Clear the results and cancel the currently running local search before starting a new search.
            places = nil
            localSearch?.cancel()
        }
    }
    
    private var boundingRegion: MKCoordinateRegion?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        suggestionController = SuggestionsTableTableViewController()
        suggestionController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: suggestionController)
        searchController.searchResultsUpdater = suggestionController
        
        searchController.searchBar.isUserInteractionEnabled = false
        searchController.searchBar.alpha = 0.5
        
        if LocationManager.instance.curLoc != nil {
            self.handleLocationUpdate()
        }
    }

    @objc func handleLocationUpdate() {
        guard let location = LocationManager.instance.curLoc else { return }
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 12_000, longitudinalMeters: 12_000)
        self.suggestionController.searchCompleter.region = region
        self.boundingRegion = region
        
        self.searchController.searchBar.isUserInteractionEnabled = true
        self.searchController.searchBar.alpha = 1.0
        
        self.tableView.reloadData()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Place the search bar in the navigation bar.
        navigationItem.searchController = searchController
        
        // Keep the search bar visible at all times.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        /*
         Search is presenting a view controller, and needs the presentation context to be defined by a controller in the
         presented view controller hierarchy.
         */
        definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    /// - Parameter suggestedCompletion: A search completion provided by `MKLocalSearchCompleter` when tapping on a search completion table row
    private func search(for suggestedCompletion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = suggestedCompletion.title
        search(using: searchRequest)
    }
    
    /// - Parameter queryString: A search string from the text the user entered into `UISearchBar`
    private func search(for queryString: String?) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = queryString
        search(using: searchRequest)
    }
    
    /// - Tag: SearchRequest
    private func search(using searchRequest: MKLocalSearch.Request) {
        // Confine the map search area to an area around the user's current location.
        if let region = boundingRegion {
            searchRequest.region = region
        }
        
        // Use the network activity indicator as a hint to the user that a search is in progress.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start { [weak self] (response, error) in
            guard error == nil else {
                self?.displaySearchError(error)
                return
            }
            
            self?.places = response?.mapItems
            
            // Used when setting the map's region in `prepareForSegue`.
            self?.boundingRegion = response?.boundingRegion
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    private func displaySearchError(_ error: Error?) {
        if let error = error as NSError?, let errorString = error.userInfo[NSLocalizedDescriptionKey] as? String {
            let alertController = UIAlertController(title: "Could not find any places.", message: errorString, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
}

extension AddEditLocationsTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard LocationManager.instance.curLoc != nil else { return 1 }
        return places?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Add & Remove Locations"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard LocationManager.instance.curLoc != nil else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = NSLocalizedString("Waiting for location detection", comment: "Waiting for location table cell")
            let spinner = UIActivityIndicatorView(style: .gray)
            spinner.startAnimating()
            cell.accessoryView = spinner
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseID.resultCell.rawValue, for: indexPath) as! SelectableAddressTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        if let mapItem = places?[indexPath.row] {
            cell.updateViews(mapItem: mapItem)
            let location = extractRetailLocationFromLocation(location: mapItem), isSelected = existingLocations.contains(where: { existingLocation in
                return existingLocation.identifier == location.identifier
            })
            if isSelected {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
        
        return cell
    }
}

extension AddEditLocationsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // tableView.deselectRow(at: indexPath, animated: true)
        
        // guard locationManager.currentLocation != nil else { return }
        guard LocationManager.instance.curLoc != nil else { return }
        
        if tableView == suggestionController.tableView, let suggestion = suggestionController.completerResults?[indexPath.row] {
            searchController.isActive = false
            searchController.searchBar.text = suggestion
            search(for: suggestion)
        }
        
        if tableView == self.tableView {
            
            if let location = places?[indexPath.row] {
                self.searchDelegate?.addLocation(location: location)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            if let location = places?[indexPath.row] {
                self.searchDelegate?.removeLocation(location: location)
            }
        }
    }
}

extension AddEditLocationsTableViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        // The user tapped search on the `UISearchBar` or on the keyboard. Since they didn't
        // select a row with a suggested completion, run the search with the query text in the search field.
        search(for: searchBar.text)
    }
}

protocol AddEditLocationsTableViewControllerDelegate: NSObjectProtocol {
    func addLocation(location: MKMapItem)
    func removeLocation(location: MKMapItem)
}
