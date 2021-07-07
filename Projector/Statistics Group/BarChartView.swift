//
//  BarChartView.swift
//  Projector
//
//  Created by Serginjo Melnik on 04.07.2021.
//  Copyright © 2021 Serginjo Melnik. All rights reserved.
//

import UIKit

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

//dataBase
struct BarData {
    let index: Int
    let percentage: CGFloat
    let color: UIColor
}

//custom cell based on GenericCell
class BarChartCell: GenericCell<BarData>{
    
    let indexLabel: UILabel = {
        let label = UILabel()
        label.text = "31"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    let barFillView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 4
        return view
    }()
    
    let dotView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    lazy var barTrackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 4
        view.addSubview(barFillView)
        
        self.barFillView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        self.barFillHeightConstraint = self.barFillView.heightAnchor.constraint(equalTo: view.heightAnchor)
        self.barFillHeightConstraint.isActive = true
        
        return view
    }()
    
    //color bar height constraint
    var barFillHeightConstraint: NSLayoutConstraint!
    
    override var item: BarData!{
        didSet{
            
            //visible or hidden text
            indexLabel.textColor = item.index % 6 == 0 ? .lightGray : .clear
            
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
            
            //issue fix
            //diactivate old constraint & than set new & activate
            barFillHeightConstraint.isActive = false
            self.barFillHeightConstraint = self.barFillView.heightAnchor.constraint(equalTo: barTrackView.heightAnchor, multiplier: item.percentage)
            barFillHeightConstraint.isActive = true
            
            //configure color
            self.barFillView.backgroundColor = item.color
        }
    }
    
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


//---------------------------------------- must be for both calendar and statistics ------------------------------
extension BarChartController {
    //accept Date and return MonthMetadata object
    func monthMetadata(for baseDate: Date) throws -> MonthMetadata{
        //asks calendar for the number of days in basedate's month. return first day
        guard
            let numberOfDaysInMonth = calendar.range(
                of: .day,
                in: .month,
                for: baseDate)?.count,
            let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: baseDate))
            
            else{
                throw CalendarDataError.metadataGeneration
        }
        
        //which day of the week first day of month falls on
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        return MonthMetadata(
            numberOfDays: numberOfDaysInMonth,
            firstDay: firstDayOfMonth,
            firstDayWeekday: firstDayWeekday)
        
    }
    
    //takes day and return an array of days
    func generateDaysInMonth (for baseDate: Date) -> [Day] {
        //calls metadata function for object
        guard let metadata = try? monthMetadata(for: baseDate) else {
            fatalError("An error occurred when generating the metadata for \(baseDate)")
        }
        //extract values from object
        let numberOfDaysInMonth = metadata.numberOfDays//31
        
        
        
        let firstDayOfMonth = metadata.firstDay
        
        //adds extra bit to begining of month if needed
        let days: [Day] = (1...numberOfDaysInMonth)
            .map { day in
                
                // calculate the offset
                let dayOffset = day - 1//day = 1....
                
                // adds of substructs an offset from Date for new day
                return generateDay(offsetBy: dayOffset, for: firstDayOfMonth)
        }
        
        return days
    }
    
    // 7 : Generate Days For Calendar
    func generateDay( offsetBy dayOffset: Int, for baseDate: Date) -> Day {
        
        let date = calendar.date( byAdding: .day, value: dayOffset, to: baseDate) ?? baseDate
        
        return Day( date: date, number: self.dateFormatter.string(from: date), isSelected: false, isWithinDisplayedMonth: true,  containEvent: false)
    }
    
    
    
    enum CalendarDataError: Error {
        case metadataGeneration
    }
}

//VC contain collection view (chart)
class BarChartController: GenericController<BarChartCell, BarData, UICollectionReusableView>, UICollectionViewDelegateFlowLayout{
    
    let calendar = Calendar(identifier: .gregorian)
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    var baseDate = Date()
    lazy var days = generateDaysInMonth(for: self.baseDate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(days.count)
        
        //set number of items color & pasing struct
         for (index, value) in days.enumerated(){
            let randomInt = Int.random(in: 0...2)
            let color: UIColor
            if randomInt == 0 {
                color = .red
            }else if randomInt == 1 {
                color = .blue
            }else{
                color = .green
            }
            let random = Float.random(in: 0..<1)
            
        //BarData struct is .init ????????????????????????????????????????????????????????????????????????
            items.append(.init(index: index, percentage: CGFloat(random), color: color))
        }
        
        collectionView.reloadData()
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 14, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}
