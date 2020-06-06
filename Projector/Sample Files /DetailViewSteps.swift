////
////  DetailViewSteps.swift
////  Projector
////
////  Created by Serginjo Melnik on 19.04.2020.
////  Copyright © 2020 Serginjo Melnik. All rights reserved.
////
//
//import UIKit
//
//class StepsCollectionView: UIStackView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
//    
//    
//    //var switchArray = [UISwitch]()
//    
//    
//    
//    //Database
//    var project: ProjectList?
//    
//    //MARK: Initialization
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupSteps()
//    }
//    
//    required init(coder: NSCoder) {
//        super.init(coder: coder)
//        setupSteps()
//    }
//    
//    //here creates a horizontal collectionView inside stackView
//    let stepsCollectionView: UICollectionView = {
//        
//        //instance for UICollectionView purposes
//        let layout = UICollectionViewFlowLayout()
//        
//        //changing default direction of scrolling
//        layout.scrollDirection = .vertical
//        
//        //becouse every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
//        // & also we need to specify how "big" it needs to be
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        
//        collectionView.backgroundColor = UIColor.clear
//        
//        //deactivate default constraints
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        
//        return collectionView
//    }()
//    
//    func setupSteps(){
//        // Add a collectionView to the stackView
//        addArrangedSubview(stepsCollectionView)
//        
//        // ?? here we specify delegate & datasourse for generating our individual horizontal cells
//        stepsCollectionView.dataSource = self
//        stepsCollectionView.delegate = self
//        
//        //Class is need to be registered in order of using inside
//        stepsCollectionView.register(StepsCell.self, forCellWithReuseIdentifier: cellId)
//        
//        //CollectionView constraints
//        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": stepsCollectionView]))
//        
//        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": stepsCollectionView]))
//    }
//    
//    //size
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        return CGSize(width: 167.0, height: 100)
//        
//    }
//    
//    //number of cells
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        
//        if let numberOfSteps = project?.steps{
//            return numberOfSteps
//        }
//        
//        return 0
//    }
//    
//    //define the cell
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! StepsCell
//        cell.layer.borderColor = UIColor.lightGray.cgColor
//        cell.layer.borderWidth = 7
//        cell.layer.cornerRadius = 12
//        
//        
//        if let projectSTEP = project?.projectStep[indexPath.row]{
//            cell.stepNameLabel.text = projectSTEP.name
//            cell.completedSwitch.isOn = projectSTEP.complete
//        }
//        cell.completedSwitch.tag = indexPath.row
//        
//        /*
//        switchArray.append(cell.completedSwitch)
//        print("this is a number of switches in array:", switchArray.count)*/
//        
//        //cell.stepCompleteSwitch.addTarget(self, action: #selector(itemCompleted(sender:)), for: .valueChanged)
//        cell.completedSwitch.addTarget(DetailViewController.instance, action: #selector(DetailViewController.instance.itemCompleted(sender:)), for: .valueChanged)
//        
//        return cell
//    }
//    
//    //turn cells to be selectable
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    
//    //action when user selects the cell
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//    }
//    //makes cells deselectable
//    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    //define color of deselected cell
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//    
//    }
//    
//}
//
//class StepsCell: UICollectionViewCell{
//    
//    //initializers
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        setupViews()
//    }
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    let stepNameLabel: UILabel = {
//        let label = UILabel()
//        label.text = "some text"
//        label.font = UIFont.systemFont(ofSize: 15)
//        label.textColor = UIColor.darkGray
//        return label
//    }()
//    
//    let completedSwitch: UISwitch = {
//        let swtch = UISwitch()
//        return swtch
//    }()
//    
//    func setupViews(){
//        //backgroundColor = UIColor.yellow
//        addSubview(stepNameLabel)
//        addSubview(completedSwitch)
//        
//        stepNameLabel.frame = CGRect(x: 18, y: 5, width: frame.width, height: 40)
//        completedSwitch.frame = CGRect(x: 18, y: 40, width: 49, height: 31)
//    }
//}
//
