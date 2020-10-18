//
//  StatisticsStackView.swift
//  Projector
//
//  Created by Serginjo Melnik on 10.10.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import Foundation
import RealmSwift

//Label that perform counting animation
class CountingLabel: UILabel {
    
    //animation logic
    var labelDisplayLink: AnimationDisplayLink?
    
    init(startValue: Double, actualValue:Double, animationDuration: Double) {
        super.init(frame: .zero)
        self.text = "\(Int(startValue))%"
        self.textColor = UIColor.init(displayP3Red: 104/255, green: 104/255, blue: 104/255, alpha: 1)
        self.font = UIFont.boldSystemFont(ofSize: 29)
        self.textAlignment = .center
        //passing all data required for animation
        self.labelDisplayLink = AnimationDisplayLink(label: self, shape: nil, startValue: startValue, actualValue: actualValue, animationDuration: animationDuration)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//Progress shape
class ProgressShapeLayer: CAShapeLayer {
    override init(layer: Any) {
        super.init(layer: layer)
    }
    //animation logic
    var shapeDisplayLink: AnimationDisplayLink?
    
    init(strokeColor: CGColor, arcCenter: CGPoint, strokeEnd: CGFloat, startValue: Double, actualValue:Double, animationDuration: Double) {
        super.init()
        self.path = UIBezierPath(arcCenter: arcCenter, radius: 60 , startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true).cgPath
        self.strokeColor = strokeColor
        self.lineWidth = 12
        self.lineCap = CAShapeLayerLineCap.round
        //rotate layer
        self.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        self.fillColor = UIColor.clear.cgColor
        self.strokeEnd = strokeEnd
        
        self.shapeDisplayLink = AnimationDisplayLink(label: nil, shape: self, startValue: startValue, actualValue: actualValue, animationDuration: animationDuration)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// logic for animation
class AnimationDisplayLink: NSObject{
    //timer object that refresh 60 time a second
    var displayLink: CADisplayLink?
    //two objects for calculation, label of shape
    let label: UILabel?
    let shape: CAShapeLayer?
    
    //start point for animation
    var animationStartDate = Date()
    //value starts by
    let startValue: Double
    //value ends by
    var actualValue: Double
    //animation duration
    let animationDuration: Double
    
    init(label: UILabel?, shape: CAShapeLayer?, startValue: Double, actualValue: Double, animationDuration: Double) {
        
        self.startValue = startValue
        self.actualValue = actualValue
        self.animationDuration = animationDuration
        
        self.label = label
        self.shape = shape
        
        // ! declare before super.init
        super.init()
        
        displayLink = CADisplayLink(target: self, selector: #selector(handleUpdate))
        displayLink?.add(to: .main, forMode: .default)
    }
    
    @objc func handleUpdate(){
        
        //every refresh it would be defined again
        let now = Date()
        //difference bwn start app time & every screen refresh
        let elapseTime = now.timeIntervalSince(animationStartDate)
        //when animation reaches end value
        if elapseTime > animationDuration {
            label?.text = "\(Int(actualValue))%"
            shape?.strokeEnd = CGFloat(actualValue / 100)
        }else{
            //percentage
            let percentageOfDuration = elapseTime / animationDuration
            let value = startValue + round(percentageOfDuration * (actualValue - startValue))
            label?.text = "\(Int(value))%"
            shape?.strokeEnd = CGFloat(value / 100)
        }
    }
    
}

//Contain counting values and they description
class DataStackView: UIStackView {
    //Category
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.init(red: 104/255, green: 104/255, blue: 104/255, alpha: 1)
        return label
    }()
    // color of shape
    let circleImage: UIImageView = {
        let image = UIImageView()
        return image
    }()
    // actual value
    var countingLabel: CountingLabel?
    
    //MARK: Initialization
    init(frame: CGRect, dataCategory: String, startValue: Double, actualValue: Double, animationDuration: Double, imageName: String) {
        self.categoryLabel.text = dataCategory
        self.circleImage.image = UIImage(named: imageName)
        self.countingLabel = CountingLabel(startValue: startValue, actualValue: actualValue, animationDuration: animationDuration)
        super.init(frame: frame)
        setupStackView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupStackView()
    }
    
    func setupStackView(){
        //unwrap optional animating number
        guard let animNumber = countingLabel else { return }
        animNumber.font = UIFont.boldSystemFont(ofSize: 20)
        animNumber.textAlignment = .left
        addSubview(categoryLabel)
        addSubview(animNumber)
        addSubview(circleImage)
        
        //Constraints
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        animNumber.translatesAutoresizingMaskIntoConstraints = false
        circleImage.translatesAutoresizingMaskIntoConstraints = false
        
        animNumber.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 0).isActive = true
        animNumber.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        animNumber.widthAnchor.constraint(equalToConstant: 105).isActive = true
        animNumber.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        circleImage.centerYAnchor.constraint(equalTo: animNumber.centerYAnchor, constant: 0).isActive = true
        circleImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        circleImage.widthAnchor.constraint(equalToConstant: 8).isActive = true
        circleImage.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        categoryLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        categoryLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        categoryLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        categoryLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
}

class StatisticsStackView: UIStackView {
    
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
    let percentageLabel = CountingLabel(startValue: 0, actualValue: 76, animationDuration: 2)
    
    //progress
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
    
    //data
    let dataStackView1 = DataStackView(frame: .zero, dataCategory: "Distance", startValue: 0, actualValue: 75, animationDuration: 2, imageName: "greenCircle")
    let dataStackView2 = DataStackView(frame: .zero, dataCategory: "Completed Steps", startValue: 0, actualValue: 50, animationDuration: 2, imageName: "redCircle")
    let dataStackView3 = DataStackView(frame: .zero, dataCategory: "Investments", startValue: 0, actualValue: 35, animationDuration: 2, imageName: "blueCircle")
    
    

    func setupStackView(){
        //StackView configuration (it contains 3 others)
        let stackView = UIStackView(arrangedSubviews: [dataStackView1, dataStackView2, dataStackView3])
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
    
    //function calls by tap gesture & by viewDidLoad method in MainViewController
    @objc func progressAnimation(){
        //changing start point execute animation on object
        greenShapeLayer.shapeDisplayLink?.animationStartDate = Date()
        redShapeLayer.shapeDisplayLink?.animationStartDate = Date()
        blueShapeLayer.shapeDisplayLink?.animationStartDate = Date()
        percentageLabel.labelDisplayLink?.animationStartDate = Date()
        dataStackView3.countingLabel?.labelDisplayLink?.animationStartDate = Date()
        dataStackView2.countingLabel?.labelDisplayLink?.animationStartDate = Date()
        dataStackView1.countingLabel?.labelDisplayLink?.animationStartDate = Date()
    }
    
}
