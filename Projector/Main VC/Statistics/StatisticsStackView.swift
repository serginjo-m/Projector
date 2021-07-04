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
    
    //projects, which is statistics database
    var items: Results<ProjectList> {
        get {
            return ProjectListRepository.instance.getProjectLists()
        }
        set{
            //updates?
        }
    }
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupStackView()
    }
    
    //app lounch point
    var animationStartDate = Date()
    //Grey section background
    let backgroundUIView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue:242/255 , alpha: 1)
        view.layer.cornerRadius = 8
        return view
    }()
    
    //data
    let moneyInvestment = DataStackView(frame: .zero, dataCategory: "Money Spent", startValue: 0, actualValue: 0, animationDuration: 2, imageName: "greenCircle", units: "$")
    let timeSpent = DataStackView(frame: .zero, dataCategory: "Time Spent", startValue: 0, actualValue: 0, animationDuration: 2, imageName: "redCircle", units: "hrs")
    let fuelConsumption = DataStackView(frame: .zero, dataCategory: "Fuel Spent", startValue: 0, actualValue: 0, animationDuration: 2, imageName: "blueCircle", units: "l")
    
    //percentage label inside track layer
    let percentageLabel = CountingLabel(startValue: 0, actualValue: 0, animationDuration: 2, units: "%")
    
    //progress shapes
    let greenShapeLayer = ProgressShapeLayer(
        strokeColor: UIColor.init(displayP3Red: 29/255, green: 212/255, blue: 122/255, alpha: 1).cgColor,
        arcCenter: .zero,
        strokeEnd: 0,
        startValue: 0,
        actualValue: 76,
        animationDuration: 2
    )
    let redShapeLayer = ProgressShapeLayer(
        strokeColor: UIColor.init(displayP3Red: 242/255, green: 98/255, blue: 98/255, alpha: 1).cgColor,
        arcCenter: .zero,
        strokeEnd: 0,
        startValue: 0,
        actualValue: 50,
        animationDuration: 2
    )
    
    let blueShapeLayer = ProgressShapeLayer(
        strokeColor: UIColor.init(displayP3Red: 68/255, green: 135/255, blue: 209/255, alpha: 1).cgColor,
        arcCenter: .zero,
        strokeEnd: 0,
        startValue: 0,
        actualValue: 35,
        animationDuration: 2
    )
    
    //track for progress shapes
    let trackLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(arcCenter: .zero , radius: 60 , startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true).cgPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.init(red: 215/255, green: 215/255, blue:215/255 , alpha: 1).cgColor
        shape.lineWidth = 12
        shape.fillColor = UIColor.clear.cgColor
        return shape
    }()
    
    //Progress shape white background
    let whiteCircle: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(arcCenter: .zero , radius: 77 , startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true).cgPath
        shape.fillColor = UIColor.white.cgColor
        return shape
    }()
    
    
    func setupStackView(){
        //StackView configuration (it contains 3 others)
        let stackView = UIStackView(arrangedSubviews: [moneyInvestment, timeSpent, fuelConsumption])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        addSubview(backgroundUIView)
        
        layer.addSublayer(whiteCircle)
        layer.addSublayer(trackLayer)
        layer.addSublayer(greenShapeLayer)
        layer.addSublayer(redShapeLayer)
        layer.addSublayer(blueShapeLayer)
        
        addSubview(percentageLabel)
        addSubview(stackView)
        
        //tap animation feature
        backgroundUIView.translatesAutoresizingMaskIntoConstraints = false
        backgroundUIView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(progressAnimation)))
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false


        stackView.topAnchor.constraint(equalTo: backgroundUIView.topAnchor, constant: 0).isActive = true
        stackView.rightAnchor.constraint(equalTo: backgroundUIView.rightAnchor, constant: -20).isActive = true
        stackView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        stackView.widthAnchor.constraint(equalToConstant: 120).isActive = true

        backgroundUIView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        backgroundUIView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        backgroundUIView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        backgroundUIView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        percentageLabel.leftAnchor.constraint(equalTo: backgroundUIView.leftAnchor, constant: 50).isActive = true
        percentageLabel.centerYAnchor.constraint(equalTo: backgroundUIView.centerYAnchor).isActive = true
        percentageLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        percentageLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
    }
    
    //this is very interesting approach for:
    //define coordinates after layers was positioned and sized
    override func layoutSubviews() {
        super.layoutSubviews()
        
        [trackLayer, blueShapeLayer, greenShapeLayer, redShapeLayer, whiteCircle].forEach {
            $0.position = CGPoint(x: 100, y: backgroundUIView.frame.height / 2)
        }
    }
    
    
    func categoryTotalValue(key: String) -> Double {
        
        var total: Double = 0
        
        for item in items {
            
            if let money = item.money {
                total += Double(money)
            }
        }
        
        return total
    }

    
    //function calls by tap gesture & by viewDidLoad method in MainViewController
    @objc func progressAnimation(){
        
        
        // Is my project object will be every time updated?----------------------------------------------
        let totalMoneyNumber = categoryTotalValue(key: "money")
        
        
        greenShapeLayer.shapeDisplayLink?.actualValue = 75
        redShapeLayer.shapeDisplayLink?.actualValue = 40
        blueShapeLayer.shapeDisplayLink?.actualValue = 30
        percentageLabel.labelDisplayLink?.actualValue = 54
        fuelConsumption.countingLabel?.labelDisplayLink?.actualValue = 47
        timeSpent.countingLabel?.labelDisplayLink?.actualValue = 98
        moneyInvestment.countingLabel?.labelDisplayLink?.actualValue = totalMoneyNumber
        
        //-------------------- order experiment --------------------------
        greenShapeLayer.zPosition = 0
        redShapeLayer.zPosition = 1
        blueShapeLayer.zPosition = 2
        
        //changing start point execute animation on object
        greenShapeLayer.shapeDisplayLink?.animationStartDate = Date()
        redShapeLayer.shapeDisplayLink?.animationStartDate = Date()
        blueShapeLayer.shapeDisplayLink?.animationStartDate = Date()
        percentageLabel.labelDisplayLink?.animationStartDate = Date()
        fuelConsumption.countingLabel?.labelDisplayLink?.animationStartDate = Date()
        timeSpent.countingLabel?.labelDisplayLink?.animationStartDate = Date()
        moneyInvestment.countingLabel?.labelDisplayLink?.animationStartDate = Date()
    }
    
}
