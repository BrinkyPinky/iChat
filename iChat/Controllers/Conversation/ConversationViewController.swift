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
import Alamofire

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
        messagesRows = viewModel.messagesRows
        headersDatesRows = viewModel.headersDatesRows
        
        DispatchQueue.main.async {
            UIView.transition(
                with: self.conversationCollectionView,
                duration: 0.15,
                options: [.curveEaseInOut,.transitionCrossDissolve],
                animations: { self.conversationCollectionView.reloadData() }
            )
        }
    }
    
    // MARK: Send Message Button Action
    
    @objc func sendMessageButtonPressed() {
        guard messageTextView.text != "" && messageTextView.text != "Message" else { return }
        
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
}
