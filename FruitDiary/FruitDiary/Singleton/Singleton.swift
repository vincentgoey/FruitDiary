//
//  Singleton.swift
//  FruitDiary
//
//  Created by Kai Xuan on 10/02/2020.
//  Copyright © 2020 Kai Xuan. All rights reserved.
//

import Foundation

class Singleton: NSObject {
    
    static let shared: Singleton = Singleton()
    
    var availableFruits = FruitsViewModel()
}
