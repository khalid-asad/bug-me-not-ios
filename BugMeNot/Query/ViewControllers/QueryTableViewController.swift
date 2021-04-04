//
//  QueryTableViewController.swift
//  BugMeNot
//
//  Created by Khalid Asad on 4/3/21.
//  Copyright © 2021 Khalid Asad. All rights reserved.
//

import PlatformCommon
import UIKit

final class QueryTableViewController: UIViewController {
    
    private var viewModel: QueryViewModel!
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    private var searchController: UISearchController!
    private var searchQuery: String?
    
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 128 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let viewModel = viewModel.items[safe: (indexPath as NSIndexPath).row] else { return }
//        let image = viewModel.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage ?? MovieViewController.placeHolderImage
        
//        let vc = MovieDetailsViewController(model: viewModel, image: image)
//        vc.modalPresentationStyle = .fullScreen
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // When scrolling past the last cell, load the next page of data.
        if indexPath.row == viewModel.items.count - 1 , let searchQuery = searchQuery {
            fetch(query: searchQuery)
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as? QueryTableViewCell,
            let movie = viewModel.items[safe: (indexPath as NSIndexPath).row]
        else { return QueryTableViewCell() }
        
//        cell.movieNameLabel.text = movie.title
//        cell.movieDescriptionLabel.text = movie.overview
//        cell.movieImageView.image = MovieViewController.placeHolderImage
        
        // If there is a cached image, set it to the view.
        guard viewModel.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) == nil else {
            return cell
        }
        return cell
    }
}

// MARK: - Search Protocols
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
extension QueryTableViewController {
    
    /// Asynchronously reload the tableView data and end refreshing.
    private func reloadData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    /// Configure the navigation bar theme.
    private func configureNavigationBar() {
        guard let navigationController = navigationController else { return }
        let navigationBar = navigationController.navigationBar
        
        navigationBar.prefersLargeTitles = true
        navigationBar.backgroundColor = ThemeManager.navigationBarColor
        navigationBar.tintColor = ThemeManager.navigationBarTextColor
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        backButton.tintColor = ThemeManager.navigationBarTextColor
        navigationItem.backBarButtonItem = backButton
        
        title = "BugMeNot"
    }
    
    /// Configure the Table View.
    private func configureTableView() {
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = view.frame.width
        let displayHeight: CGFloat = view.frame.height
        
        // Set the table view within the frame
        tableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight))
        tableView.register(QueryTableViewCell.classForCoder(), forCellReuseIdentifier: "MyCell")

        // Estimate a row height of 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        
        // Set the data source and delegate to the current VC
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.backgroundColor = ThemeManager.backgroundColor
        
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
    private func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Website (i.e. theathletic.com)"
        searchController.searchBar.delegate = self
        
        configureSearchBarTheme()
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    /// Configures the Search Bar Segmented Control and Bar Button Item themes.
    private func configureSearchBarTheme() {
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([.foregroundColor: ThemeManager.navigationBarTextColor], for: .normal)
        let segmentedControl = UISegmentedControl.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        segmentedControl.setTitleTextAttributes([.foregroundColor: ThemeManager.navigationBarTextColor], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: ThemeManager.complementedColor], for: .selected)
        segmentedControl.selectedSegmentTintColor = ThemeManager.backgroundColor
        searchController.searchBar.tintColor = ThemeManager.navigationBarTextColor
    }
    
    /// Function to search by cancelling previous requests, and creating a new one.
    private func search(for text: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reloadTableView), object: nil)
        clearDataAndCache()
        searchQuery = text
        perform(#selector(reloadTableView), with: nil, afterDelay: 0.25)
    }
    
    /// Clears the cache in the model, then reloads the data in the table view.
    private func clearDataAndCache() {
        viewModel.items.removeAll()
        viewModel.cache.removeAllObjects()
        reloadData()
    }
    
    /// Reload the table view by fetching the search query.
    @objc
    private func reloadTableView() {
        // If search query is non-existent then wipe the data and cache and return
        guard let searchQuery = searchQuery, !searchQuery.isEmpty else {
            clearDataAndCache()
            return
        }
        fetch(query: searchQuery)
    }
    
    /// Fetches the search results from the API through the model.
    private func fetch(query: String) {
        viewModel.fetch(query: query) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Error: \(String(describing: error))")
            } else {
                self.reloadData()
            }
        }
    }
}
