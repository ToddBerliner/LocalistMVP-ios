/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Table view controller used to display suggested search criteria.
*/

import UIKit
import MapKit

class SuggestionsTableTableViewController: UITableViewController {
    
    let searchCompleter = MKLocalSearchCompleter()
    var completerResults: [String]?
    
    convenience init() {
        self.init(style: .plain)
        searchCompleter.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SuggestedCompletionTableViewCell.self, forCellReuseIdentifier: SuggestedCompletionTableViewCell.reuseID)
    }
}

extension SuggestionsTableTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completerResults?.count ?? 0
    }

    /// - Tag: HighlightFragment
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SuggestedCompletionTableViewCell.reuseID, for: indexPath)

        if let suggestion = completerResults?[indexPath.row] {
            // Each suggestion is a MKLocalSearchCompletion with a title, subtitle, and ranges describing what part of the title
            // and subtitle matched the current query string. The ranges can be used to apply helpful highlighting of the text in
            // the completion suggestion that matches the current query fragment.
            cell.textLabel?.attributedText = NSMutableAttributedString(string: suggestion)
            cell.detailTextLabel?.attributedText = NSMutableAttributedString(string: "Search Nearby")
        }

        return cell
    }
    
    private func createHighlightedString(text: String, rangeValues: [NSValue]) -> NSAttributedString {
//        let attributes = [NSAttributedString.Key.backgroundColor: UIColor(named: "suggestionHighlight")! ]
        let highlightedString = NSMutableAttributedString(string: text)
        
        // Each `NSValue` wraps an `NSRange` that can be used as a style attribute's range with `NSAttributedString`.
//        let ranges = rangeValues.map { $0.rangeValue }
//        ranges.forEach { (range) in
//            highlightedString.addAttributes(attributes, range: range)
//        }
        
        return highlightedString
    }
}

extension SuggestionsTableTableViewController: MKLocalSearchCompleterDelegate {
    
    /// - Tag: QueryResults
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // As the user types, new completion suggestions are continuously returned to this method.
        // Overwrite the existing results, and then refresh the UI with the new results.
        
        var names = Set<String>()
        for result in completer.results {
            names.insert(result.title)
        }
        
        completerResults = Array(names)
        tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Handle any errors returned from MKLocalSearchCompleter.
        if let error = error as NSError? {
            logError(message: "MKLocalSearchCompleter, didFailWithError", error: error.localizedDescription)
            print("MKLocalSearchCompleter encountered an error: \(error.localizedDescription)")
        }
    }
}

extension SuggestionsTableTableViewController: UISearchResultsUpdating {

    /// - Tag: UpdateQuery
    func updateSearchResults(for searchController: UISearchController) {
        // Ask `MKLocalSearchCompleter` for new completion suggestions based on the change in the text entered in `UISearchBar`.
        searchCompleter.queryFragment = searchController.searchBar.text ?? ""
    }
}

private class SuggestedCompletionTableViewCell: UITableViewCell {
    
    static let reuseID = "SuggestedCompletionTableViewCellReuseID"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        logError(message: "SuggestedCompletionTableViewCell, requiredInit aDecoder", error: "init(coder:) has not been implemented")
        fatalError("init(coder:) has not been implemented")
    }
}
