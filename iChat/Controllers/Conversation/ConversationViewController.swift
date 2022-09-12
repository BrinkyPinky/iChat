//
//  ConversationViewController.swift
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

protocol ConversationDisplayLogic: AnyObject {
    func displayFullname(viewModel: Conversation.fullnameLabel.ViewModel)
    func displayMessages(viewModel: Conversation.Messages.ViewModel)
}

class ConversationViewController: UIViewController, ConversationDisplayLogic {
    
    @IBOutlet var conversationCollectionView: UICollectionView!
    @IBOutlet var MessageToolBar: UIToolbar! //setup in file (Extension + Appearance)
    let messageTextView = UITextView() //logic in file (Extension + TextFieldDelegate)
    let sendMessageButton = UIButton() //setup in file (Extension + Appearance)
    let stackViewForToolBar = UIStackView() //setup in file (Extension + Appearance)
    
    var messagesRows: [[CellIdentifiable]] = [[]]
    var headersDatesRows: [CellIdentifiable] = []
    
    var interactor: ConversationBusinessLogic?
    var router: (NSObjectProtocol & ConversationRoutingLogic & ConversationDataPassing)?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() //in file (Extension + Appearance)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onKeyboardWillChangeFrame),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        ) //in file (Extension + Keyboard)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )  //in file (Extension + Keyboard)
        interactor?.stopObservingMessages()
        self.tabBarController?.tabBar.isHidden = false
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .clear
        navigationController?.navigationBar.scrollEdgeAppearance = nil
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.compactAppearance = nil
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
    
    // MARK: Display FullName
    
    func displayFullname(viewModel: Conversation.fullnameLabel.ViewModel) {
        title = viewModel.fullname
    }
    
    // MARK: Display Messages
    
    func displayMessages(viewModel: Conversation.Messages.ViewModel) {
        let isItFirstDisplayingMessages = headersDatesRows.isEmpty
        let currentContentSize = self.conversationCollectionView.contentSize.height // before reloadData()
        let currentOffset = conversationCollectionView.contentOffset.y
        
        messagesRows = viewModel.messagesRows
        headersDatesRows = viewModel.headersDatesRows
        DispatchQueue.main.async {
            UIView.transition(
                with: self.conversationCollectionView,
                duration: 0.15,
                options: [.transitionCrossDissolve, .curveEaseInOut],
                animations: {}
            )
            
            self.conversationCollectionView.reloadData()
            self.conversationCollectionView.layoutIfNeeded()
            
            // scroll to bottom if the messages are displayed for the first time else stay in the same place
            if isItFirstDisplayingMessages {
                let heightOfContentSize = self.conversationCollectionView.contentSize.height
                let heightOfCollectionView = self.conversationCollectionView.frame.height
                let targetYPosition = heightOfContentSize - heightOfCollectionView
                
                self.conversationCollectionView.contentOffset.y = targetYPosition
            } else if currentOffset == 0 {
                let heightOfContentSize = self.conversationCollectionView.contentSize.height
                let targetYPosition = heightOfContentSize - currentContentSize
                
                self.conversationCollectionView.contentOffset.y = targetYPosition
            }
        }
    }
    
    // MARK: Send Message Button Action
    
    @objc func sendMessageButtonPressed() {
        let request = Conversation.SendMessage.Request(messageText: messageTextView.text)
        interactor?.sendMessage(request: request)
        messageTextView.text = ""
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = ConversationInteractor()
        let presenter = ConversationPresenter()
        let router = ConversationRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == 0 {
            interactor?.getMessages(isNeedToUpLimit: true)
        }
    }
}

// MARK: Content of CollectionView

extension ConversationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: Header content
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        headersDatesRows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let messageHeaderCellModel = headersDatesRows[indexPath.section]
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "MessageHeader",
                for: indexPath
            ) as! ConversationCollectionHeaderView
            
            headerView.messageHeaderCellModel = messageHeaderCellModel
            
            return headerView
        default:
            fatalError("Unexpected element kind")
        }
    }
    
    // MARK: Cell Content
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messagesRows[section].count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let messageCellModel = messagesRows[indexPath.section][indexPath.row]
        
        if messageCellModel.cellIdentifier == "OutgoingMessage" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messageCellModel.cellIdentifier, for: indexPath) as! ConversationCollectionViewCellOutgoingMessage
            cell.messageCellModel = messageCellModel
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messageCellModel.cellIdentifier, for: indexPath) as! ConversationCollectionViewCellIncomingMessage
            cell.messageCellModel = messageCellModel
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            
            let deleteForYourself = UIAction(
                title: "Delete for yourself",
                image: UIImage(systemName: "xmark.bin"),
                identifier: nil,
                discoverabilityTitle: nil,
                attributes: .destructive,
                state: .off
            ) { _ in
                print("delete for yourself")
            }
            
            let deleteForAll = UIAction(
                title: "Delete for all",
                image: UIImage(systemName: "xmark.bin"),
                identifier: nil,
                discoverabilityTitle: nil,
                attributes: .destructive,
                state: .off
            ) { _ in
                print("delete for all")
            }
            
            
            return UIMenu(
                title: "",
                image: nil,
                identifier: nil,
                options: .displayInline,
                children: [deleteForYourself, deleteForAll]
            )
        }
        
        return config
    }
}
