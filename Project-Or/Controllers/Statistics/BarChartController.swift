//
//  BarChartController.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 30/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class BarChartController: GenericController<BarChartCell, BarData, UICollectionReusableView>, UICollectionViewDelegateFlowLayout{
    
    var statistics: Results<StatisticData>{
        get{
            return ProjectListRepository.instance.getStatisticNotes()
        }
        set{
            //
        }
    }
    
    var groupedDictionary = [ Date: [StatisticData]]()
    let calendar = Calendar(identifier: .gregorian)
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    var baseDate = Date()
    lazy var days = generateDaysInMonth(for: self.baseDate)
    
    var moneyMaximumValue: CGFloat = 0.0
    var timeMaximumValue: CGFloat = 0.0
    var fuelMaximumValue: CGFloat = 0.0

    func setStatisticsDictionary(){
        groupedDictionary = Dictionary(grouping: statistics, by: { (statistic) -> Date in
            let date = calendar.startOfDay(for: statistic.date)
            return date
        })
    }
    
    func setCategoriesMaximumValue(){
        
        for (_, value) in days.enumerated(){
            
            var moneyValue: CGFloat = 0.0
            var timeValue: CGFloat = 0.0
            var fuelValue: CGFloat = 0.0
            
            if let array = groupedDictionary[value.date]{
                
                for item in array{
                    switch item.category{
                    case "money":
                        moneyValue += CGFloat(item.number)
                    case "time":
                        timeValue += CGFloat(item.number)
                    case "fuel":
                        fuelValue += CGFloat(item.number)
                    default:
                        break
                    }
                }
            }
            
            if moneyValue > moneyMaximumValue {
                moneyMaximumValue = moneyValue
            }
            if timeValue > timeMaximumValue{
                timeMaximumValue = timeValue
            }
            if fuelValue > fuelMaximumValue{
                fuelMaximumValue = fuelValue
            }
        }
        
    }
    
    func defineItemsArray(){

        items.removeAll()
        
        for (index, value) in days.enumerated(){
            
            var moneyValue: CGFloat = 0.0
            var timeValue: CGFloat = 0.0
            var fuelValue: CGFloat = 0.0
            
            if let array = groupedDictionary[value.date]{
                
                for item in array{
                    switch item.category{
                    case "money":
                        moneyValue += CGFloat(item.number)
                    case "time":
                        timeValue += CGFloat(item.number)
                    case "fuel":
                        fuelValue += CGFloat(item.number)
                    default:
                        break
                    }
                }
            }
            
            var moneyPercentage: CGFloat = 0.0
            var timePercentage: CGFloat = 0.0
            var fuelPercentage: CGFloat = 0.0
            
            if moneyMaximumValue > 0 {
                moneyPercentage = moneyValue / moneyMaximumValue
            }
            
            if timeMaximumValue > 0 {
                timePercentage = timeValue / timeMaximumValue
            }
            
            if fuelMaximumValue > 0 {
                fuelPercentage = fuelValue / fuelMaximumValue
            }
            
            let lastItem = days.count == index + 1 ? true : false
            
            
            items.append(.init(index: index, isLastOne: lastItem, categoryPercentage: CategoryValue(money: moneyPercentage, time: timePercentage, fuel: fuelPercentage)))
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = CGFloat((Int(view.frame.width) / days.count))
        
        let cellSize = CGSize.init(width: width, height: view.frame.height)

        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
