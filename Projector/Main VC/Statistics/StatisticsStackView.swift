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
    
    let numbersComparisonLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 31)
        label.textColor = UIColor.init(displayP3Red: 104/255, green: 104/255, blue: 104/255, alpha: 1)
        return label
    }()
    
    let lineSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(red: 215/255, green: 215/255, blue:215/255 , alpha: 1)
        return view
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.init(displayP3Red: 104/255, green: 104/255, blue: 104/255, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }()
    
    func setupStackView(){
 
        
        //gray background
        addSubview(backgroundUIView)
        
        layer.addSublayer(whiteCircle)
        layer.addSublayer(trackLayer)
        layer.addSublayer(greenShapeLayer)
        //
        addSubview(percentageLabel)
        addSubview(numbersComparisonLabel)
        addSubview(lineSeparator)
        addSubview(descriptionLabel)
        
        //tap animation feature
        backgroundUIView.translatesAutoresizingMaskIntoConstraints = false
        backgroundUIView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(progressAnimation)))
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false

        backgroundUIView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        backgroundUIView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        backgroundUIView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        backgroundUIView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        percentageLabel.leftAnchor.constraint(equalTo: backgroundUIView.leftAnchor, constant: 50).isActive = true
        percentageLabel.centerYAnchor.constraint(equalTo: backgroundUIView.centerYAnchor).isActive = true
        percentageLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        percentageLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        numbersComparisonLabel.topAnchor.constraint(equalTo: topAnchor, constant: 40).isActive = true
        numbersComparisonLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 200).isActive = true
        numbersComparisonLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        numbersComparisonLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        lineSeparator.topAnchor.constraint(equalTo: numbersComparisonLabel.bottomAnchor, constant: 23).isActive = true
        lineSeparator.leftAnchor.constraint(equalTo: numbersComparisonLabel.leftAnchor, constant: 0).isActive = true
        lineSeparator.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        lineSeparator.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        descriptionLabel.topAnchor.constraint(equalTo: lineSeparator.bottomAnchor, constant: 17).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: numbersComparisonLabel.leftAnchor, constant: 0).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        descriptionLabel.heightAnchor.constraint(equalToConstant: 38).isActive = true
        
    }
    
    //this is very interesting approach for:
    //define coordinates after layers was positioned and sized
    override func layoutSubviews() {
        super.layoutSubviews()
        
        [trackLayer, greenShapeLayer, whiteCircle].forEach {//redShapeLayer, blueShapeLayer
            $0.position = CGPoint(x: 100, y: backgroundUIView.frame.height / 2)
        }
    }
    
    
    //function calls by tap gesture & by viewDidLoad method in MainViewController
    @objc func progressAnimation(){
        
        //all steps in all projects
        var totalSteps: Double = 0
        //completed steps in all projects
        var completedSteps: Double = 0
        // steps completion percentage
        var projectPercentage: Double = 0
        
        //length of completed step number
        var numberLength = 1
        
        //iterate through all projects
        for project in self.items {
            //check if steps there's steps in the project
            if project.projectStep.count > 0{
                //iterate through steps
                for step in project.projectStep {
                    //count steps
                    totalSteps += 1
                    // complete or not
                    if step.complete == true {
                        //if complete - add
                        completedSteps += 1
                    }
                }
            }
            //avoid division by 0
            if totalSteps > 0 {
                projectPercentage = (completedSteps / totalSteps) * 100
            }
        }
        
        greenShapeLayer.shapeDisplayLink?.actualValue = projectPercentage
        percentageLabel.labelDisplayLink?.actualValue = projectPercentage
        
        //complete steps color configuration
        if completedSteps >= 1000 {
            numberLength = 4
        }else if completedSteps >= 100{
            numberLength = 3
        }else if completedSteps >= 10{
            numberLength = 2
        }
        
        let greenColor: UIColor = UIColor.init(displayP3Red: 29/255, green: 212/255, blue: 122/255, alpha: 1)
        let myString = "\(Int(completedSteps)) / \(Int(totalSteps))"
        let mutableString = NSMutableAttributedString(string: myString, attributes: [NSMutableAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 31)])
        mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: greenColor, range: NSRange(location:0, length:numberLength))
        //description
        if items.count > 0{
            descriptionLabel.text = "steps completed in \(items.count) projects"
        }else{
            descriptionLabel.text = "no steps - no progress"
        }
        
        numbersComparisonLabel.attributedText = mutableString
        
        //changing start point execute animation on object
        greenShapeLayer.shapeDisplayLink?.animationStartDate = Date()
        percentageLabel.labelDisplayLink?.animationStartDate = Date()

    }
    
}
