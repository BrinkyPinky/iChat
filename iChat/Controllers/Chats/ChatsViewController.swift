//
//  ChatsTableViewController.swift
//  iChat
//
//  Created by Егор Шилов on 05.09.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import RealmSwift

protocol ChatsDisplayLogic: AnyObject {
    func displayChats(viewModel: Chats.gettingChats.ViewModel)
}

class ChatsViewController: UITableViewController, ChatsDisplayLogic {
    
    var interactor: ChatsBusinessLogic?
    var router: (NSObjectProtocol & ChatsRoutingLogic & ChatsDataPassing)?
    
    private var chatsRows = [CellIdentifiable]()
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interactor?.getChats()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        FireBaseDatabaseManager.shared.userOnline()
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
     
    func displayChats(viewModel: Chats.gettingChats.ViewModel) {
        chatsRows = viewModel.rows
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = ChatsInteractor()
        let presenter = ChatsPresenter()
        let router = ChatsRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
}

extension ChatsViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatsRows.count
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatViewModelCell = chatsRows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: chatViewModelCell.cellIdentifier, for: indexPath) as! ChatsTableViewCell
        
        cell.chatsViewModelCell = chatViewModelCell
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatViewModelCell = chatsRows[indexPath.row]
        interactor?.selectedRow(row: chatViewModelCell)
        router?.routeToConversation(segue: nil)
    }
}
