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
    func displayTitle(viewModel: Conversation.userTitleLabel.ViewModel)
    func displayMessages(viewModel: Conversation.Messages.ViewModel)
}

class ConversationViewController: UIViewController, ConversationDisplayLogic {
    
    @IBOutlet var conversationCollectionView: UICollectionView!
    @IBOutlet var MessageToolBar: UIToolbar! //setup in file (Extension + Appearance)
    let messageTextView = UITextView() //logic in file (Extension + TextFieldDelegate)
    let sendMessageButton = UIButton() //setup in file (Extension + Appearance)
    let stackViewForToolBar = UIStackView() //setup in file (Extension + Appearance)
    @IBOutlet var scrollDownButton: UIButton!
    
    var messagesRows: [[CellIdentifiable]] = [[]]
    var headersDatesRows: [CellIdentifiable] = []
    
    var interactor: ConversationBusinessLogic?
    var router: (NSObjectProtocol & ConversationDataPassing)?
    
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
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .clear
        navigationController?.navigationBar.scrollEdgeAppearance = nil
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.compactAppearance = nil
    }
    
    // MARK: Display FullName
    
    func displayTitle(viewModel: Conversation.userTitleLabel.ViewModel) {
        self.navigationItem.titleView = setTitle(
            title: viewModel.fullname,
            isActive: viewModel.isOnline
        )
    }
    
    // MARK: Display Messages
    
    func displayMessages(viewModel: Conversation.Messages.ViewModel) {
        reloadConversationCollectionView(viewModel: viewModel) { [unowned self] in
            messagesRows = viewModel.messagesRows
            headersDatesRows = viewModel.headersDatesRows
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
        let conversationCollectionContentHeight = conversationCollectionView.contentSize.height
        let conversationCollectionViewHeight = conversationCollectionView.frame.height
        
        let currentOffset = conversationCollectionContentHeight - conversationCollectionViewHeight
        
        if scrollView.contentOffset.y == 0 {
            interactor?.getMessages(isNeedToUpLimit: true)
        } else if scrollView.contentOffset.y < currentOffset - 50 {
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: .curveEaseInOut) {
                    self.scrollDownButton.layer.opacity = 1
                } completion: { _ in
                    self.scrollDownButton.isEnabled = true
                }
        } else if scrollView.contentOffset.y > currentOffset - 100 {
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: .curveEaseInOut) {
                    self.scrollDownButton.layer.opacity = 0
                } completion: { _ in
                    self.scrollDownButton.isEnabled = false
                }
        }
    }
    
    @IBAction func scrollDownButtonTapped(_ sender: Any) {
        let section = conversationCollectionView.numberOfSections - 1
        let row = conversationCollectionView.numberOfItems(inSection: section) - 1
        let indexPath = IndexPath(row: row, section: section)
        
        conversationCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
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
                withReuseIdentifier: messageHeaderCellModel.cellIdentifier,
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messageCellModel.cellIdentifier, for: indexPath) as! ConversationCollectionViewCellMessage
        
        cell.messageCellModel = messageCellModel
        
        return cell
        
    }
    
    // MARK: ContextMenu
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        guard let cell = collectionView.cellForItem(at: indexPath) as? ConversationCollectionViewCellMessage else { return nil }

        let targetedPreview = UITargetedPreview(view: cell.viewBackgroundTheMessage)
        targetedPreview.parameters.shadowPath = UIBezierPath()

        return targetedPreview
        
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        guard let cell = collectionView.cellForItem(at: indexPath) as? ConversationCollectionViewCellMessage else { return nil }
        
        let targetedPreview = UITargetedPreview(view: cell.viewBackgroundTheMessage)
        targetedPreview.parameters.shadowPath = UIBezierPath()
        
        return targetedPreview
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let cellViewModel = messagesRows[indexPath.section][indexPath.row]
        
        let config = UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            let copyText = UIAction(
                title: "Copy message",
                image: UIImage(systemName: "doc.on.doc")
            ) { _ in
                self.interactor?.copyMessageToClipboard(cellViewModel: cellViewModel)
            }
            
            let deleteForYourself = UIAction(
                title: "Delete for yourself",
                image: UIImage(systemName: "xmark.bin"),
                attributes: .destructive
            ) { _ in
                self.interactor?.deleteMessageForYourself(cellViewModel: cellViewModel)
            }
            
            let deleteForAll = UIAction(
                title: "Delete for all",
                image: UIImage(systemName: "xmark.bin"),
                attributes: .destructive
            ) { _ in
                self.interactor?.deleteMessageForAll(cellViewModel: cellViewModel)
            }
            
            let subMenu = UIMenu(
                title: "",
                image: nil,
                identifier: nil,
                options: .displayInline,
                children: [copyText]
            )
            
            return UIMenu(
                title: "",
                image: nil,
                identifier: nil,
                options: .displayInline,
                children: [subMenu, deleteForYourself, deleteForAll]
            )
        }
        
        return config
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let request = Conversation.ReadMessage.Request(displayingCell: messagesRows[indexPath.section][indexPath.row])
        interactor?.readMessage(request: request)
    }
}
