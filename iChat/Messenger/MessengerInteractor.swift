//
//  MessengerInteractor.swift
//  iChat
//
//  Created by Егор Шилов on 28.08.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol MessengerBusinessLogic {
    func doSomething(request: Messenger.Something.Request)
}

protocol MessengerDataStore {
    //var name: String { get set }
}

class MessengerInteractor: MessengerBusinessLogic, MessengerDataStore {
    
    var presenter: MessengerPresentationLogic?
    var worker: MessengerWorker?
    //var name: String = ""
    
    // MARK: Do something
    
    func doSomething(request: Messenger.Something.Request) {
        worker = MessengerWorker()
        worker?.doSomeWork()
        
        let response = Messenger.Something.Response()
        presenter?.presentSomething(response: response)
    }
}
