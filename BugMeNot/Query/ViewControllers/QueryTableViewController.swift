//
//  QueryTableViewController.swift
//  BugMeNot
//
//  Created by Khalid Asad on 4/3/21.
//  Copyright © 2021 Khalid Asad. All rights reserved.
//

import PlatformCommon
import UIKit

enum SearchResultSortMode: String, CaseIterable {
    case none = "None"
    case successRate = "Success Rate"
    case votes = "Votes"
    case age = "Age"
}

final class QueryTableViewController: UIViewController {
    
    private var viewModel: QueryViewModel!
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    private var searchController: UISearchController!
    private var searchQuery: String?
    private var searchScope: SearchResultSortMode? = SearchResultSortMode.none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        
        viewModel = QueryViewModel()

        configureNavigationBar()
        configureTableView()
        configureSearchController()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Upon changing the orientation of the device, reset the size of the tableView.
        tableView.frame = CGRect(
            x: 0,
            y: UIApplication.shared.statusBarFrame.size.height,
            width: view.frame.width,
            height: view.frame.height
        )
    }
}

// MARK: - Table View Protocols
extension QueryTableViewController: UITableViewDelegate, UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.items.count == 0 {
            var message: Constants {
                if searchQuery == nil || searchQuery?.isEmpty == true {
                    return .searchEmptyMessage
                } else {
                    if searchQuery?.isValidURL == true {
                        return .searchBannedInputMessage
                    } else {
                        return .searchInvalidInputMessage
                    }
                }
            }
            tableView.setEmptyMessage(message.rawValue, textColor: ThemeManager.textColor, font: ThemeManager.subHeaderFont)
        } else {
            tableView.restore()
        }
        return viewModel.items.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: QueryTableViewCell.cellIdentifier, for: indexPath) as? QueryTableViewCell,
            let login = viewModel.items[safe: (indexPath as NSIndexPath).row]
        else { return QueryTableViewCell() }
        cell.configure(login: login)
        return cell
    }
}

// MARK: - Search Bar Protocols
extension QueryTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    /// Protocol function for searching.
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        guard let searchBarText = searchBar.text else { return }
        // Search with the text from the Search Bar
        search(for: searchBarText)
    }
    
    /// Protocol function for text changing, we want to clear the cache and then search.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchBarText = searchBar.text else { return }
        // Search with the text from the Search Bar
        clearDataAndCache()
        search(for: searchBarText)
    }
    
    /// Protocol function for Scopes (so we can sort by Genres).
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchScope = SearchResultSortMode.allCases[selectedScope]
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
}

// MARK: - Private Methods
private extension QueryTableViewController {
    
    /// Asynchronously reload the tableView data and end refreshing.
    func reloadData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    /// Configure the navigation bar theme.
    func configureNavigationBar() {
        guard let navigationController = navigationController else { return }
        let navigationBar = navigationController.navigationBar
        
        navigationBar.prefersLargeTitles = false
        navigationBar.backgroundColor = ThemeManager.navigationBarColor
        navigationBar.tintColor = ThemeManager.navigationBarTextColor
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        backButton.tintColor = ThemeManager.navigationBarTextColor
        navigationItem.backBarButtonItem = backButton
        
        let imageView = UIImageView(frame: .init(x: 0, y: 0, width: 200, height: 50))
        imageView.image = #imageLiteral(resourceName: "logo")
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        title = Constants.title.rawValue
    }
    
    /// Configure the Table View.
    func configureTableView() {
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = view.frame.width
        let displayHeight: CGFloat = view.frame.height
        
        // Set the table view within the frame
        tableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight))
        tableView.register(QueryTableViewCell.classForCoder(), forCellReuseIdentifier: QueryTableViewCell.cellIdentifier)

        // Estimate a row height of 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        
        // Set the data source and delegate to the current VC
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.backgroundColor = ThemeManager.backgroundColor
        tableView.keyboardDismissMode = .onDrag
        
        view.addSubview(tableView)
        
        // Create a refresh control and target it to the reloadTableView function for any values changed
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTableView), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        // Set the initial cache and data within the model to be empty
        viewModel.cache = NSCache()
        viewModel.items = []
    }
    
    /// Configures the Search Controller in the Navigation bar.
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Constants.searchPlaceholder.rawValue
        searchController.searchBar.scopeButtonTitles = SearchResultSortMode.allCases.map { $0.rawValue }
        searchController.searchBar.delegate = self
        searchController.searchBar.keyboardType = .URL
        searchController.searchBar.keyboardAppearance = ThemeManager.keyboardAppearance
        
        configureSearchBarTheme()
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    /// Configures the Search Bar Segmented Control and Bar Button Item themes.
    func configureSearchBarTheme() {
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([.foregroundColor: ThemeManager.navigationBarTextColor], for: .normal)
        let segmentedControl = UISegmentedControl.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        segmentedControl.setTitleTextAttributes([.foregroundColor: ThemeManager.navigationBarTextColor], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: ThemeManager.complementedColor], for: .selected)
        segmentedControl.selectedSegmentTintColor = ThemeManager.backgroundColor.withAlphaComponent(0.5)
        segmentedControl.backgroundColor = ThemeManager.segmentedControlColor
        searchController.searchBar.tintColor = ThemeManager.navigationBarTextColor
    }
    
    /// Function to search by cancelling previous requests, and creating a new one.
    func search(for text: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reloadTableView), object: nil)
        clearDataAndCache()
        searchQuery = text
        perform(#selector(reloadTableView), with: nil, afterDelay: 0.25)
    }
    
    func sort() {
        guard let searchScope = self.searchScope else { return }
        self.viewModel.items = self.viewModel.items.sorted {
            switch searchScope {
            case .successRate: return $0.successRateInteger > $1.successRateInteger
            case .votes: return $0.votesInteger > $1.votesInteger
            case .age: return $0.ageDate > $1.ageDate
            case .none: return $0.originalSequence < $0.originalSequence
            }
        }
    }
    
    /// Clears the cache in the model, then reloads the data in the table view.
    func clearDataAndCache() {
        viewModel.items.removeAll()
        viewModel.cache.removeAllObjects()
        reloadData()
    }
    
    /// Reload the table view by fetching the search query.
    @objc func reloadTableView() {
        // If search query is non-existent then wipe the data and cache and return
        guard let searchQuery = searchQuery, !searchQuery.isEmpty else {
            clearDataAndCache()
            return
        }
        fetch(query: searchQuery)
    }
    
    /// Fetches the search results from the API through the model.
    func fetch(query: String) {
        viewModel.fetch(query: query) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Error: \(String(describing: error))")
            } else {
                self.sort()
                self.reloadData()
            }
        }
    }
}
