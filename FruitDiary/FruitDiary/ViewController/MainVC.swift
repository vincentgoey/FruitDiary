//
//  MainVC.swift
//  FruitDiary
//
//  Created by Kai Xuan on 09/02/2020.
//  Copyright © 2020 Kai Xuan. All rights reserved.
//

import UIKit

class MainVC: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        self.setupTabBar()
    }
    
    func setupTabBar() {
        let firstViewController = HomeVC()
        let navigationController = UINavigationController(rootViewController: firstViewController)
        navigationController.title = "Home"
//        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.tabBarItem.image = UIImage.init(named: "home_icon")
        navigationController.navigationBar.barTintColor = hexStringToUIColor(hex: appConstant.themeColor)
        
        
        let secondViewController = AboutVC()
        let secNavigationController = UINavigationController(rootViewController: secondViewController)
        secNavigationController.title = "About"
        secNavigationController.navigationBar.prefersLargeTitles = true
        secNavigationController.tabBarItem.image = UIImage.init(named: "about_icon")

        viewControllers = [navigationController, secNavigationController]
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true;
    }

}
