//
//  FruitModel.swift
//  FruitDiary
//
//  Created by Kai Xuan on 09/02/2020.
//  Copyright © 2020 Kai Xuan. All rights reserved.
//

import Foundation

struct Fruit: Decodable {
    
    var id          :Int
    var type        :String
    var vitamins    :Int
    var image       :String
    
}
