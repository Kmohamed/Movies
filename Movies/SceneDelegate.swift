//
//  SceneDelegate.swift
//  Movies
//
//  Adopts the UIScene life cycle required by the current iOS SDK (TN3187).
//  Builds the window from the Main storyboard's initial view controller,
//  preserving the app's storyboard-driven launch with no AppDelegate root setup.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window.rootViewController = storyboard.instantiateInitialViewController()
        self.window = window
        window.makeKeyAndVisible()
    }
}
