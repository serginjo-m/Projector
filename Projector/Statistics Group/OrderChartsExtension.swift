//
//  OrderChartsExtension.swift
//  Projector
//
//  Created by Serginjo Melnik on 17.07.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

extension BarChartCell{
    //--------------------------------------------------------------------------------------------------------------------
    //------------------------- calculations performs for days that are not visible. Is it an issue? ---------------------
    //--------------------------------------------------------------------------------------------------------------------
    func orderViewsByValue() -> [UIView]{
        
        guard let item = item else {
            print("item is not accessable yet!")
            return [moneyBarFillView, timeBarFillView, fuelBarFillView]
        }
        
        let money = item.categoryPercentage.money
        let time = item.categoryPercentage.time
        let fuel = item.categoryPercentage.fuel
        
        //check if some value exist
        if money > 0.0 || time > 0.0 || fuel > 0.0{
            
            var orderedViewsArray = [UIView]()
            
            // money > time || fuel
            if money >= fuel && money >= time {
                
                // money = 0
                orderedViewsArray.append(moneyBarFillView)
                
                if fuel >= time {
                    //fuel = 1
                    orderedViewsArray.append(fuelBarFillView)
                    //time = 2
                    orderedViewsArray.append(timeBarFillView)
                }else{
                    //time = 1
                    orderedViewsArray.append(timeBarFillView)
                    //fuel = 2
                    orderedViewsArray.append(fuelBarFillView)
                }
                //time > fuel || money
            }else if time >= money && time >= fuel{
                //time = 0
                orderedViewsArray.append(timeBarFillView)
                if money >= fuel {
                    //money = 1
                    orderedViewsArray.append(moneyBarFillView)
                    //fuel = 2
                    orderedViewsArray.append(fuelBarFillView)
                }else{
                    //fuel = 1
                    orderedViewsArray.append(fuelBarFillView)
                    //money = 2
                    orderedViewsArray.append(moneyBarFillView)
                }
                //fuel > time || money
            }else if fuel >= money && fuel >= time {
                //fuel = 0
                orderedViewsArray.append(fuelBarFillView)
                if money >= time {
                    //money = 1
                    orderedViewsArray.append(moneyBarFillView)
                    //time = 2
                    orderedViewsArray.append(timeBarFillView)
                }else{
                    //time = 1
                    orderedViewsArray.append(timeBarFillView)
                    //money = 2
                    orderedViewsArray.append(moneyBarFillView)
                }
            }else{
                print("Can't order Array")
            }
            
            //---------------------------------------------------------------------------------------------------------
            //            print(orderedViewsArray)
            return orderedViewsArray
        }
        
        //-------------------------------------------------------------------------------------------------------------
        //        print("nothing to order in day: \(item.index)")
        return [moneyBarFillView, timeBarFillView, fuelBarFillView]
    }
}
