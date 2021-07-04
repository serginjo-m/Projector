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
    
    //[ String : [StatisticData]]
    var groupedDictionary: [ String : [StatisticData]]? {
        
        let dictionary = Dictionary(grouping: projectStatistics) { (statistic) -> String in
            return statistic.category
        }
        
        return dictionary
    }
    
    //statistic variables
    var time: Int? {
        return categorySum(key: "time")
    }
    
    var money: Int? {
        return categorySum(key: "money")
    }
    
    var fuel: Int? {
        return categorySum(key: "fuel")
    }
    
    //calculate sum of numbers
    func categorySum(key: String) -> Int{
        
        //unwrap optional
        guard let dictionary = groupedDictionary else {return 0}
        
        // ? objects for particular key ?
        guard let array = dictionary[key] else {return 0}
        
        //total
        var sum = 0
        
        //iterate
        for item in array{
            //because I'm interested in spendings
            if item.positiveNegative == 0 {
                sum += item.number
            }
        }
        
        return sum
    }
}
