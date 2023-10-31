//
//  StatisticsStackView.swift
//  Projector
//
//  Created by Serginjo Melnik on 10.10.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class StatisticsStackView: UIStackView {
 
    var steps: Results<ProjectStep> {
        get{
            return ProjectListRepository.instance.getProjectSteps()
        }
    }
    
    var projects: Results<ProjectList> {
        get{
            return ProjectListRepository.instance.getProjectLists()
        }
    }

    var sortedCategoryPercentageArray: [Double] = []
    var categoryByInt: [Double:String] = [:]
    let colorsByCategory: [String: CGColor] = [
        "todo": UIColor.init(red: 22/255, green: 118/255, blue: 215/255, alpha: 1).cgColor,
        "inProgress": UIColor.init(red: 255/255, green: 183/255, blue: 69/255, alpha: 1).cgColor,
        "done": UIColor.init(red: 18/255, green: 190/255, blue: 120/255, alpha: 1).cgColor,
        "blocked": UIColor.init(red: 255/255, green: 82/255, blue: 82/255, alpha: 1).cgColor
    ]
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupStackView()
        updateDatabase()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupStackView()
    }
    
    var animationStartDate = Date()
    
    let backgroundUIView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 165/255, green: 202/255, blue:215/255 , alpha: 1)
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()
    
    let percentageLabel = CountingLabel(startValue: 0, actualValue: 0, animationDuration: 2, units: "")
    
    let percentageUnitsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Steps"
        label.textColor = UIColor.init(red: 126/255, green: 86/255, blue: 177/255, alpha: 1)
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    let firstProgressShapeLayer = ProgressShapeLayer(
        strokeColor: UIColor.init(red: 22/255, green: 118/255, blue: 215/255, alpha: 1).cgColor,
        arcCenter: .zero,
        strokeEnd: 0,
        startValue: 0,
        actualValue: 0,
        animationDuration: 2
    )
    
    let secondProgressShapeLayer = ProgressShapeLayer(
        strokeColor: UIColor.init(red: 255/255, green: 183/255, blue: 69/255, alpha: 1).cgColor,
        arcCenter: .zero,
        strokeEnd: 0,
        startValue: 0,
        actualValue: 0,
        animationDuration: 2
    )
    
    let thirdProgressShapeLayer = ProgressShapeLayer(
        strokeColor: UIColor.init(red: 18/255, green: 190/255, blue: 120/255, alpha: 1).cgColor,
        arcCenter: .zero,
        strokeEnd: 0,
        startValue: 0,
        actualValue: 0,
        animationDuration: 2
    )
    
    let fourthProgressShapeLayer = ProgressShapeLayer(
        strokeColor: UIColor.init(red: 255/255, green: 82/255, blue: 82/255, alpha: 1).cgColor,
        arcCenter: .zero,
        strokeEnd: 0,
        startValue: 0,
        actualValue: 0,
        animationDuration: 2
    )
    
    let trackLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(arcCenter: .zero , radius: 60 , startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true).cgPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.init(red: 226/255, green: 236/255, blue:239/255 , alpha: 1).cgColor
        shape.lineWidth = 12
        shape.fillColor = UIColor.clear.cgColor
        return shape
    }()
    
    let whiteCircle: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(arcCenter: .zero , radius: 77 , startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true).cgPath
        shape.fillColor = UIColor.white.cgColor
        return shape
    }()
    
    let darkCircle: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(arcCenter: .zero , radius: 114 , startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true).cgPath
        shape.fillColor = UIColor.init(red: 154/255, green: 188/255, blue: 201/255, alpha: 1).cgColor
        return shape
    }()
    
    let brightCircle: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(arcCenter: .zero , radius: 178 , startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true).cgPath
        shape.fillColor = UIColor.init(red: 159/255, green: 195/255, blue: 208/255, alpha: 1).cgColor
        return shape
    }()
    
    let projectsCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
        
    let lineSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(red: 154/255, green: 188/255, blue:201/255 , alpha: 1)
        return view
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()
    
    let todoCategoryView: ProgressWidgetCategoryView = {
        let color = UIColor.init(red: 22/255, green: 118/255, blue: 215/255, alpha: 1)
        let view = ProgressWidgetCategoryView(title: "Todo", color: color, frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    let inProgressCategoryView: ProgressWidgetCategoryView = {
        let color = UIColor.init(red: 255/255, green: 183/255, blue: 69/255, alpha: 1)
        let view = ProgressWidgetCategoryView(title: "In Progress", color: color, frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    let doneCategoryView: ProgressWidgetCategoryView = {
        let color = UIColor.init(red: 18/255, green: 190/255, blue: 120/255, alpha: 1)
        let view = ProgressWidgetCategoryView(title: "Done", color: color, frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    let blockedCategoryView: ProgressWidgetCategoryView = {
        let color = UIColor.init(red: 255/255, green: 82/255, blue: 82/255, alpha: 1)
        let view = ProgressWidgetCategoryView(title: "Blocked", color: color, frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var categoryViewsArray = [todoCategoryView, inProgressCategoryView, doneCategoryView, blockedCategoryView]
    
    lazy var progressCategoriesStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: self.categoryViewsArray)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        stack.axis = .vertical
        return stack
    }()
    
    func setupStackView(){
        
        addSubview(backgroundUIView)
        backgroundUIView.layer.addSublayer(brightCircle)
        backgroundUIView.layer.addSublayer(darkCircle)
        
        
        layer.addSublayer(whiteCircle)
        layer.addSublayer(trackLayer)
        layer.addSublayer(firstProgressShapeLayer)
        layer.addSublayer(secondProgressShapeLayer)
        layer.addSublayer(thirdProgressShapeLayer)
        layer.addSublayer(fourthProgressShapeLayer)

        addSubview(lineSeparator)
        addSubview(percentageLabel)
        addSubview(percentageUnitsLabel)
        addSubview(projectsCountLabel)
        addSubview(descriptionLabel)
        addSubview(progressCategoriesStack)
        
        backgroundUIView.translatesAutoresizingMaskIntoConstraints = false
        backgroundUIView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(progressAnimation)))
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false

        backgroundUIView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        backgroundUIView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        backgroundUIView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        backgroundUIView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        percentageLabel.leftAnchor.constraint(equalTo: backgroundUIView.leftAnchor, constant: 50).isActive = true
        percentageLabel.centerYAnchor.constraint(equalTo: backgroundUIView.centerYAnchor, constant: -10).isActive = true
        percentageLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        percentageLabel.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        percentageUnitsLabel.centerXAnchor.constraint(equalTo: percentageLabel.centerXAnchor).isActive = true
        percentageUnitsLabel.topAnchor.constraint(equalTo: percentageLabel.bottomAnchor).isActive = true
        percentageUnitsLabel.heightAnchor.constraint(equalToConstant: 14).isActive = true
        percentageUnitsLabel.widthAnchor.constraint(equalToConstant: 36).isActive = true
        
        projectsCountLabel.topAnchor.constraint(equalTo: topAnchor, constant: 21).isActive = true
        projectsCountLabel.leftAnchor.constraint(equalTo: progressCategoriesStack.leftAnchor).isActive = true
        projectsCountLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        projectsCountLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        lineSeparator.topAnchor.constraint(equalTo: projectsCountLabel.bottomAnchor, constant: 16).isActive = true
        lineSeparator.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
        lineSeparator.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        lineSeparator.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        descriptionLabel.topAnchor.constraint(equalTo: lineSeparator.bottomAnchor, constant: 17).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: projectsCountLabel.leftAnchor, constant: 0).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        descriptionLabel.heightAnchor.constraint(equalToConstant: 76).isActive = true
        
        progressCategoriesStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        progressCategoriesStack.widthAnchor.constraint(equalToConstant: 135).isActive = true
        progressCategoriesStack.heightAnchor.constraint(equalToConstant: 120).isActive = true
        progressCategoriesStack.topAnchor.constraint(equalTo: lineSeparator.bottomAnchor, constant: 5).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        [trackLayer, firstProgressShapeLayer, secondProgressShapeLayer, thirdProgressShapeLayer, fourthProgressShapeLayer, whiteCircle, darkCircle, brightCircle].forEach {
            $0.position = CGPoint(x: 100, y: backgroundUIView.frame.height / 2)
        }
    }
    
    
    func updateDatabase(){
        //clear old data
        sortedCategoryPercentageArray.removeAll()
        categoryByInt.removeAll()
        
        let stepsGroupedByCategory = Dictionary.init(grouping: steps, by: { step in
            return step.category
        })
        
        var percentsArray: [Double] = []
        
        for array in stepsGroupedByCategory.values{
            
            if array.count > 0 {
                guard let item = array.first else {return}
                
                let percentage: Double = (Double(array.count) / Double(steps.count)) * 100
                 
                percentsArray.append(percentage)
                let category = item.category
                
                categoryByInt[percentage] = category
                
                switch category {
                case "todo":
                    self.todoCategoryView.sectionValueNumber = array.count
                case "inProgress":
                    self.inProgressCategoryView.sectionValueNumber = array.count
                case "done":
                    self.doneCategoryView.sectionValueNumber = array.count
                case "blocked":
                    self.blockedCategoryView.sectionValueNumber = array.count
                default:
                    break
                }
            }
        }
        
        sortedCategoryPercentageArray = percentsArray.sorted(by: { a, b in
            return a > b
        })
        
    }
    
    @objc func progressAnimation(){

        let strokesArray = [firstProgressShapeLayer, secondProgressShapeLayer, thirdProgressShapeLayer, fourthProgressShapeLayer]
    
        categoryViewsArray.forEach { view in
            view.sectionValueNumber = 0
        }
        
        strokesArray.forEach { shapeLayer in
            shapeLayer.shapeDisplayLink?.actualValue = 0
        }
        
        updateDatabase()
        
        for (key, percentage) in sortedCategoryPercentageArray.enumerated() {
            
            let progressShape = strokesArray[key]
            
            progressShape.shapeDisplayLink?.actualValue = percentage
            
            if let category = categoryByInt[percentage]{
                progressShape.strokeColor = colorsByCategory[category]
            }
            
            progressShape.shapeDisplayLink?.animationStartDate = Date()
        }
        
        percentageLabel.labelDisplayLink?.actualValue = Double(steps.count)
        percentageLabel.labelDisplayLink?.animationStartDate = Date()
        categoryViewsArray.forEach{$0.sectionValue.labelDisplayLink?.animationStartDate = Date()}
        
        projectsCountLabel.attributedText = prepareMutableString(
            string: "In \(projects.count) projects:",
            fontSize: 20,
            color: UIColor.init(red: 126/255, green: 86/255, blue: 177/255, alpha: 1),
            location: 3,
            numberValue: projects.count)
        
    }
    
    fileprivate func prepareMutableString(string: String, fontSize: CGFloat, color: UIColor, location: Int, numberValue: Int) -> NSMutableAttributedString{
        
        let mutableString = NSMutableAttributedString(string: string, attributes: [NSMutableAttributedString.Key.font: UIFont.boldSystemFont(ofSize: fontSize)])
        
        var numberLength = 1
        
        if numberValue >= 1000 {
            numberLength = 4
        }else if numberValue >= 100{
            numberLength = 3
        }else if numberValue >= 10{
            numberLength = 2
        }
        
        mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location:location, length:numberLength))
        
        return mutableString
    }
}
