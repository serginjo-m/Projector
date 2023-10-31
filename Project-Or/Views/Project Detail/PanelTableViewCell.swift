//
//  PanelTableViewCell.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 30/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit
class PanelTableViewCell: UITableViewCell {
    
    var data: StatisticData? {
        didSet {
            guard let data = data else { return }
    
            if data.positiveNegative == 0{
                plusMinusSymbol = "-"
            }else{
                plusMinusSymbol = "+"
            }
        
            taskLabel.text = "\(plusMinusSymbol)\(data.number)  \(data.comment)"
        }
    }
    
    var plusMinusSymbol = ""
  
    let taskLabel: UILabel = {
        let label = UILabel()
        label.text = "-100$ Surface Cleaner"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .white
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear

        addSubview(taskLabel)

        taskLabel.frame = CGRect(x: 0, y: 0, width: 250, height: 30)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
