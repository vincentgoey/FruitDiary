//
//  FruitEntryModel.swift
//  FruitDiary
//
//  Created by Kai Xuan on 10/02/2020.
//  Copyright © 2020 Kai Xuan. All rights reserved.
//

import Foundation

struct FruitEntryModel: Decodable {
    var id      : Int
    var date    : String
    var fruit   : [FruitEntryDetailsModel]
}

struct FruitEntryDetailsModel: Decodable{
    var fruitId     : Int
    var fruitType   : String
    var amount      : Int
}
