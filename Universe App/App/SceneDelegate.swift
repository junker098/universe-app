//
//  SceneDelegate.swift
//  Universe App
//
//  Created by Yuriy on 18.03.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = injectViewController()
        window.makeKeyAndVisible()
        self.window = window
    }
    
    func injectViewController() -> UIViewController {
        let photoService = PHPhotoService()
        let coreDataService = CoreDataService()
        let viewModel = PhotoLibraryViewModel(photoService: photoService,
                                              coreDataService: coreDataService
        )
        return PhotoLibraryViewController(viewModel: viewModel)
    }
}

