//
//  FruitEntryListViewModel.swift
//  FruitDiary
//
//  Created by Kai Xuan on 10/02/2020.
//  Copyright © 2020 Kai Xuan. All rights reserved.
//

import Foundation

struct FruitEntryListViewModel {
    private var fruitEntries = [FruitEntryModel]()
    
    mutating func retrieveData(fruitsEntries: [FruitEntryModel]) {
        
        self.fruitEntries.removeAll()

        fruitsEntries.forEach { (fruitEntry) in
            self.fruitEntries.append(fruitEntry)
        }
        
    }
    
    func count() -> Int {
        return self.fruitEntries.count
    }
    
    func modelAt(_ index: Int) -> FruitEntryModel {
        return self.fruitEntries[index]
    }
    
    func toArray() -> [FruitEntryModel] {
        return self.fruitEntries.map{$0}
    }
}
