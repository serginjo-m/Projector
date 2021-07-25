//
//  BarChartView.swift
//  Projector
//
//  Created by Serginjo Melnik on 04.07.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class BarChartView: UIView{
    
    //VC contain all chart collection view based on GENERICS
    let barChartController = BarChartController(scrollDirection: .horizontal)
    
    //view that contain chart VC inside custom StackView
    lazy var barsContainerView: UIView = {
        let view = UIView()
        
        //using custom StackView to add chart VC
        view.stack(NSLayoutConstraint.Axis.horizontal, views: barChartController.view, spacing: 0)
       
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //add & configure subview
        setupView()
    }
    
    //add & configuration views
    func setupView(){
        
        addSubview(barsContainerView)
        
        barsContainerView.translatesAutoresizingMaskIntoConstraints = false
        //use custom uiview extension, that setup bound to superview bounds
        barsContainerView.fillSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//custom cell based on GenericCell
class BarChartCell: GenericCell<BarData>{
    
    override var item: BarData!{
        didSet{

            //visible or hidden text
            indexLabel.textColor = item.index % 6 == 0 ? UIColor.init(white: 0.4, alpha: 1) : .clear
            
            //index == number string
            indexLabel.text = String(item.index + 1)
            
            //dot indicator configuration (small or bigger)
            if item.index % 6 == 0{
                dotViewHeightConstraint.constant = 6
                dotViewWidthConstraint.constant = 6
                dotView.layer.cornerRadius = 4
            }else{
                dotViewHeightConstraint.constant = 4
                dotViewWidthConstraint.constant = 4
                dotView.layer.cornerRadius = 2
            }
            
            
            //contain views ordered by value
            let orderedViewsArray = orderViewsByValue()
            
            //add views regard its value & define anchors(with shortcut)
            orderedViewsArray.forEach({
                
                barTrackView.addSubview($0)
                
                $0.anchor(top: nil, leading: barTrackView.leadingAnchor, bottom: barTrackView.bottomAnchor, trailing: barTrackView.trailingAnchor)
                
            })
            
            //some trick that fix an issue
            self.moneyBarFillHeightConstraint = self.moneyBarFillView.heightAnchor.constraint(equalTo: barTrackView.heightAnchor)
            self.timeBarFillHeightConstraint = self.timeBarFillView.heightAnchor.constraint(equalTo: barTrackView.heightAnchor)
            self.fuelBarFillHeightConstraint = self.fuelBarFillView.heightAnchor.constraint(equalTo: barTrackView.heightAnchor)

            self.moneyBarFillHeightConstraint.isActive = true
            self.timeBarFillHeightConstraint.isActive = true
            self.fuelBarFillHeightConstraint.isActive = true



            //issue fix
            //diactivate old constraint & than set new & activate
            moneyBarFillHeightConstraint.isActive = false
            timeBarFillHeightConstraint.isActive = false
            fuelBarFillHeightConstraint.isActive = false
            
            
            //----------------------------------------------------------------------------------------------------
            // 1.    So, if I give multipliers static value, issue with reusing disappeares
            // 2.    Need something to do with 2+ maximums in the same day
            // 3.    Calculations performs for days that are not visible. Is it an issue?
            //----------------------------------------------------------------------------------------------------
            
            
            
            self.moneyBarFillHeightConstraint = self.moneyBarFillView.heightAnchor.constraint(equalTo: barTrackView.heightAnchor, multiplier: item.categoryPercentage.money)
            self.timeBarFillHeightConstraint = self.timeBarFillView.heightAnchor.constraint(equalTo: barTrackView.heightAnchor, multiplier: item.categoryPercentage.time)
            self.fuelBarFillHeightConstraint = self.fuelBarFillView.heightAnchor.constraint(equalTo: barTrackView.heightAnchor, multiplier: item.categoryPercentage.fuel)
            
            
            moneyBarFillHeightConstraint.isActive = true
            timeBarFillHeightConstraint.isActive = true
            fuelBarFillHeightConstraint.isActive = true
            
        }
    }
    
    let indexLabel: UILabel = {
        let label = UILabel()
        label.text = "31"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    //green chart bar
    let moneyBarFillView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(displayP3Red: 29/255, green: 212/255, blue: 122/255, alpha: 1)
        view.layer.cornerRadius = 5
        return view
    }()
    //blue chart bar
    let timeBarFillView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(displayP3Red: 68/255, green: 135/255, blue: 209/255, alpha: 1)
        view.layer.cornerRadius = 5
        return view
    }()
    //red chart bar
    let fuelBarFillView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(displayP3Red: 242/255, green: 98/255, blue: 98/255, alpha: 1)
        view.layer.cornerRadius = 5
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
    
    //color bar height constraint
    var moneyBarFillHeightConstraint: NSLayoutConstraint!
    var timeBarFillHeightConstraint: NSLayoutConstraint!
    var fuelBarFillHeightConstraint: NSLayoutConstraint!
    
    //contain dot indicator
    var dotViewContainer = UIView().withHeight(height: 24)
    //indicator height
    var dotViewHeightConstraint: NSLayoutConstraint!
    //indicator width
    var dotViewWidthConstraint: NSLayoutConstraint!
    
    override func setupViews() {
        super.setupViews()
        
        clipsToBounds = false
        //Cell StackView custom configuration
        stack(views:
            stack(.horizontal, views:
                UIView().withWidth(3),//blank view on the left side
                barTrackView,//actual bar view
                UIView().withWidth(3)),//blank view on the right side
                dotViewContainer,//container for dots indicator
            indexLabel, spacing: 0)//numbers indicator
        
        dotViewContainer.addSubview(dotView)//adds indicator to container
        
        dotView.centerInSuperview()//center in container
        dotViewWidthConstraint = dotView.widthAnchor.constraint(equalToConstant: 6)
        dotViewHeightConstraint = dotView.heightAnchor.constraint(equalToConstant: 6)
        dotViewWidthConstraint.isActive = true
        dotViewHeightConstraint.isActive = true
        dotView.layer.cornerRadius = 5
        //center to number
        dotView.centerXAnchor.constraint(equalTo: indexLabel.centerXAnchor).isActive = true
    }
}

//dataBase
struct BarData {
    let index: Int
    let categoryPercentage: CategoryValue
}

struct CategoryValue{
    let money: CGFloat
    let time: CGFloat
    let fuel: CGFloat
}

//VC contain collection view (chart)
class BarChartController: GenericController<BarChartCell, BarData, UICollectionReusableView>, UICollectionViewDelegateFlowLayout{
    
    var statistics: Results<StatisticData>{
        get{
            
            return ProjectListRepository.instance.getStatisticNotes()
        }
        set{
            //update
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
    
    //category month max value
    var moneyMaximumValue: CGFloat = 0.0
    var timeMaximumValue: CGFloat = 0.0
    var fuelMaximumValue: CGFloat = 0.0
    
    
    //all statistics, sorted by Date
    func setStatisticsDictionary(){
        groupedDictionary = Dictionary(grouping: statistics, by: { (statistic) -> Date in
            let date = calendar.startOfDay(for: statistic.date)
            return date
        })
    }
    
    //Maximum values need to be find before any pecentage calculations
    func setCategoriesMaximumValue(){
        
        for (_, value) in days.enumerated(){
            
            //this is total day value by category
            var moneyValue: CGFloat = 0.0
            var timeValue: CGFloat = 0.0
            var fuelValue: CGFloat = 0.0
            
            //iterate through dictionary(current month)
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
            
            //check for max value in this month
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
        
        for (index, value) in days.enumerated(){
            
            //this is total day value by category
            var moneyValue: CGFloat = 0.0
            var timeValue: CGFloat = 0.0
            var fuelValue: CGFloat = 0.0
            
            //iterate through dictionary(current month)
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
            
            
            //Need to avoid division by "0"
            if moneyMaximumValue > 0 {
                moneyPercentage = moneyValue / moneyMaximumValue
            }
            
            if timeMaximumValue > 0 {
                timePercentage = timeValue / timeMaximumValue
            }
            
            if fuelMaximumValue > 0 {
                fuelPercentage = fuelValue / fuelMaximumValue
            }
            
            //BarData struct is .init (because of declare GENERICS TYPE,
            //where: GenericCell<U>, U == BarChartCell, BarData
            items.append(.init(index: index, categoryPercentage: CategoryValue(money: moneyPercentage, time: timePercentage, fuel: fuelPercentage)))
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //grouped Dictionary
        setStatisticsDictionary()
        //find categoies maximum values
        setCategoriesMaximumValue()
        //calculate percentage & define items array
        defineItemsArray()
        
        collectionView.reloadData()
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 16, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}

