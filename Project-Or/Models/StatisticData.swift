//
//  StatisticData.swift
//  Projector
//
//  Created by Serginjo Melnik on 31.01.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class StatisticData: Object {
    
    @objc dynamic var positiveNegative = 0
    @objc dynamic var number = 0
    @objc dynamic var comment = ""
    @objc dynamic var category = ""
    @objc dynamic var date = Date()
    @objc dynamic var id = UUID().uuidString
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    
}
