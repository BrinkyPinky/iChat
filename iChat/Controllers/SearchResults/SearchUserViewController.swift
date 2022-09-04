//
//  SearchUserViewController.swift
//  iChat
//
//  Created by Егор Шилов on 01.09.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol SearchUserDisplayLogic: AnyObject {
    func presentUsers(viewModel: SearchUser.Search.ViewModel)
}

class SearchUserViewController: UITableViewController, SearchUserDisplayLogic {
        
    var searchController = UISearchController()
    
    var interactor: SearchUserBusinessLogic?
    var router: (NSObjectProtocol & SearchUserRoutingLogic & SearchUserDataPassing)?
    
    private var rows: [CellIdentifiable] = []
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        let viewController = self
        let interactor = SearchUserInteractor()
        let presenter = SearchUserPresenter()
        let router = SearchUserRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: Provide text in search field to interactor
    
    func provideSearchText(with text: String?) {
        let request = SearchUser.Search.Request(searchText: text)
        interactor?.getUsersData(request: request)
    }
    
    func provideSelectedUser(with user: CellIdentifiable) {
        let request = SearchUser.Selected.Request(selectedUser: user)
        interactor?.getSelectedUser(request: request)
        router?.routeToChats(segue: nil)
    }
    
    func presentUsers(viewModel: SearchUser.Search.ViewModel) {
        rows = viewModel.rows
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension SearchUserViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        provideSearchText(with: searchController.searchBar.text)
    }
}

extension SearchUserViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.cellIdentifier, for: indexPath) as! UserTableViewCell
        
        cell.cellModel = cellViewModel
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        provideSelectedUser(with: rows[indexPath.row])
    }
}
