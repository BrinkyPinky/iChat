//
//  SceneDelegate.swift
//  iChat
//
//  Created by Егор Шилов on 25.08.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        guard UserLoginDataManager.shared.email != nil else {
            showLoginViewController()
            return
        }
        
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        
        let email = UserLoginDataManager.shared.email
        let password = UserLoginDataManager.shared.password
        
        FireBaseAuthManager.shared.login(email: email!, password: password!) { error in
            guard let _ = error else { return }
            showLoginViewController()
        }
        
        func showLoginViewController() {
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "NavigationControllerLogin") as! UINavigationController
            window = UIWindow(windowScene: windowScene)
            window?.rootViewController = rootViewController
            window?.makeKeyAndVisible()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        FireBaseDatabaseManager.shared.userOnline()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        FireBaseDatabaseManager.shared.userOffline()
    }
    
    
}

