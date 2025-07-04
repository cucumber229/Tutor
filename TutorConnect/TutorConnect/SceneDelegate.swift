//
//  SceneDelegate.swift
//  TutorConnect
//
//  Created by Дмитрий Леонтьев on 13.06.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        self.window = window
        let appCoordintator = AppCoordinator(window: window)
        
        if UserDefaults.standard.value(forKey: "uid") == nil {
            appCoordintator.start()
        } else {
            appCoordintator.goToProfile()
        }
    }
}
