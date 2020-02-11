//
//  AboutVC.swift
//  FruitDiary
//
//  Created by Kai Xuan on 09/02/2020.
//  Copyright © 2020 Kai Xuan. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "About"
          
        let aboutLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        aboutLabel.text = "Fruit Diary Assessment From Vincent Goey. This Project doesn't contain xib and storyboard in order to build faster. No third party libraries, API address can be found in API.swift, Api Calling method using URLSession. This project is using MVVM. Business logic follow according what API behaviour."
        aboutLabel.numberOfLines = 0
        aboutLabel.textColor = .black
        aboutLabel.textAlignment = NSTextAlignment.center
        
        self.view.addSubview(aboutLabel)
        
    }
}
