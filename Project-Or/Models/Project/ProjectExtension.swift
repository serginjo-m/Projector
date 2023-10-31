//
//  ProjectProtocolExtension.swift
//  Projector
//
//  Created by Serginjo Melnik on 23.06.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

extension ProjectList {
    var groupedDictionary: [ String : [StatisticData]]? {
        let dictionary = Dictionary(grouping: projectStatistics) { (statistic) -> String in
            return statistic.category
        }
        return dictionary
    }
    
    var time: Int? {
        return categorySum(key: "time")
    }
    
    var money: Int? {
        return categorySum(key: "money")
    }
    
    var fuel: Int? {
        return categorySum(key: "fuel")
    }
    
    func categorySum(key: String) -> Int{
    
        guard let dictionary = groupedDictionary else {return 0}
        
        guard let array = dictionary[key] else {return 0}
        
        var sum = 0
        
        for item in array{
        
            if item.positiveNegative == 0 {
                sum += item.number
            }
        }
        
        return sum
    }
}
