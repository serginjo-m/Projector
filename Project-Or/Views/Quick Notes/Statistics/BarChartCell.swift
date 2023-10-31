//
//  BarChartCell.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 30/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class BarChartCell: GenericCell<BarData>{
    
    override var item: BarData!{
        didSet{
            
            indexLabel.textColor = item.index % 6 == 0 || item.isLastOne ? UIColor.init(white: 0.4, alpha: 1) : .clear
            
            indexLabel.text = String(item.index + 1)
            
            if item.index % 6 == 0{
                dotViewHeightConstraint.constant = 4
                dotViewWidthConstraint.constant = 4
                dotView.layer.cornerRadius = 2
            }else{
                dotViewHeightConstraint.constant = 2
                dotViewWidthConstraint.constant = 2
                dotView.layer.cornerRadius = 1
            }
            
            let orderedViewsArray = orderViewsByValue()
            
            orderedViewsArray.forEach({
                
                barTrackView.addSubview($0)
                
                $0.anchor(top: nil, leading: barTrackView.leadingAnchor, bottom: barTrackView.bottomAnchor, trailing: barTrackView.trailingAnchor)
            })
           
            if moneyBarFillHeightConstraint != nil || timeBarFillHeightConstraint != nil || fuelBarFillHeightConstraint != nil {
                
                moneyBarFillHeightConstraint.isActive = false
                timeBarFillHeightConstraint.isActive = false
                fuelBarFillHeightConstraint.isActive = false
            }
            
            self.moneyBarFillHeightConstraint = self.moneyBarFillView.heightAnchor.constraint(equalTo: barTrackView.heightAnchor, multiplier: item.categoryPercentage.money)
            self.timeBarFillHeightConstraint = self.timeBarFillView.heightAnchor.constraint(equalTo: barTrackView.heightAnchor, multiplier: item.categoryPercentage.time)
            self.fuelBarFillHeightConstraint = self.fuelBarFillView.heightAnchor.constraint(equalTo: barTrackView.heightAnchor, multiplier: item.categoryPercentage.fuel)
            
            if item.categoryPercentage.fuel == 1.0 && item.categoryPercentage.time == 1.0 && item.categoryPercentage.money == 1.0{
                print("Let's devide by 3")
            }else if item.categoryPercentage.money == 1.0 {
                if item.categoryPercentage.money == item.categoryPercentage.time{
                    
                    print("money == time")
                }else if item.categoryPercentage.money == item.categoryPercentage.fuel{
                    print("money == fuel")
                }
            }else if item.categoryPercentage.time == 1.0{
                if item.categoryPercentage.time == item.categoryPercentage.money {
                    print("time == money")
                }else if item.categoryPercentage.time == item.categoryPercentage.fuel{
                    print("time == fuel")
                }
                
            }else if item.categoryPercentage.fuel == 1.0{
                if item.categoryPercentage.fuel == item.categoryPercentage.money{
                    print("fuel == money")
                }else if item.categoryPercentage.fuel == item.categoryPercentage.time{
                    print("fuel == time")
                }
            }
            
            moneyBarFillHeightConstraint.isActive = true
            timeBarFillHeightConstraint.isActive = true
            fuelBarFillHeightConstraint.isActive = true
            
        }
    }
    
    let indexLabel: UILabel = {
        let label = UILabel()
        label.text = "31"
        label.font = UIFont.systemFont(ofSize: 8)
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    let moneyBarFillView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(displayP3Red: 29/255, green: 212/255, blue: 122/255, alpha: 1)
        view.layer.cornerRadius = 4
        return view
    }()
    
    let timeBarFillView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(displayP3Red: 68/255, green: 135/255, blue: 209/255, alpha: 1)
        view.layer.cornerRadius = 4
        return view
    }()
    
    let fuelBarFillView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(displayP3Red: 242/255, green: 98/255, blue: 98/255, alpha: 1)
        view.layer.cornerRadius = 4
        return view
    }()
    
    let dotView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0.4, alpha: 1)
        return view
    }()

    lazy var barTrackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 4
        return view
    }()
    
    var moneyBarFillHeightConstraint: NSLayoutConstraint!
    var timeBarFillHeightConstraint: NSLayoutConstraint!
    var fuelBarFillHeightConstraint: NSLayoutConstraint!
    
    var dotViewContainer = UIView().withHeight(height: 24)
    
    var dotViewHeightConstraint: NSLayoutConstraint!
    
    var dotViewWidthConstraint: NSLayoutConstraint!
    
    override func setupViews() {
        super.setupViews()
        
        clipsToBounds = false
        
        stack(views:
            stack(.horizontal, views:
                UIView().withWidth(2),
                barTrackView,
                UIView().withWidth(2)),
                dotViewContainer,
            indexLabel, spacing: 0)
        
        dotViewContainer.addSubview(dotView)
        
        dotView.centerInSuperview()
        dotViewWidthConstraint = dotView.widthAnchor.constraint(equalToConstant: 6)
        dotViewHeightConstraint = dotView.heightAnchor.constraint(equalToConstant: 6)
        dotViewWidthConstraint.isActive = true
        dotViewHeightConstraint.isActive = true
        dotView.layer.cornerRadius = 2
        dotView.centerXAnchor.constraint(equalTo: indexLabel.centerXAnchor).isActive = true
    }
}
