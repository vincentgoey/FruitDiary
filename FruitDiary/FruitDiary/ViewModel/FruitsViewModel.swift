//
//  FruitsViewModel.swift
//  FruitDiary
//
//  Created by Kai Xuan on 09/02/2020.
//  Copyright © 2020 Kai Xuan. All rights reserved.
//

import Foundation

struct FruitsViewModel: Decodable {
    private var fruits = [Fruit]()
    
    mutating func retrieveData(fruits: [Fruit]) {
        //Clear Old data
        self.fruits.removeAll()
        //Add new data
        fruits.forEach { (fruit) in
            self.fruits.append(fruit)
        }
    }
    
    func count() -> Int {
        return self.fruits.count
    }
    
    func modelAt(_ index: Int) -> Fruit {
        return self.fruits[index]
    }
}
