//
//  RecentActivitiesCV.swift
//  Projector
//
//  Created by Serginjo Melnik on 31.10.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

class StepNumbersCollectionView: UIStackView,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    //this property need for cells
    private let cellID = "cellId"
    
    var stepValues = [String]()
    
    //Database
    var step = ProjectStep() {
        didSet{
            //define values of a project
            defineProjectsValues()
        }
    }
    
    //cell settings
    let cellSettingsArray: [String] = ["TOTAL COST", "DISTANCE", "SPENDINGS"]
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    //here creates a horizontal collectionView inside stackView
    let stepNumbersCollectionView: UICollectionView = {
        
        //instance for UICollectionView purposes
        let layout = UICollectionViewFlowLayout()
        
        //changing default direction of scrolling
        layout.scrollDirection = .horizontal
        
        //spacing...
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //layout.itemSize = CGSize(width: 120, height: 45)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        
        //because every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        
        collectionView.backgroundColor = UIColor.clear
        
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    func setupView(){
        
        // Add a collectionView to the stackView
        addArrangedSubview(stepNumbersCollectionView)
        
        // ?? here we specify delegate & datasourse for generating our individual horizontal cells
        stepNumbersCollectionView.dataSource = self
        stepNumbersCollectionView.delegate = self
        
        //Class is need to be registered in order of using inside
        stepNumbersCollectionView.register(StepNumbersCell.self, forCellWithReuseIdentifier: cellID)
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": stepNumbersCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": stepNumbersCollectionView]))
    }
    
    //size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //projects value string
        let item = stepValues[indexPath.row]
        
        //cell size will be dynamically calculated based on string size
        var itemSize = item.size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 26)])
        
        
        
        //increase height for description label
        itemSize.height = 48
        itemSize.width += 20.0
        
        //because if size too small description will be covered
        if itemSize.width < 95 {
            return CGSize(width: 95, height: itemSize.height)
        }
        
        return itemSize
        
    }
    //number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    //define the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! StepNumbersCell
        
        
        //here is IMPORTANT part, when I pass settings for every cell
        cell.buttonTitleLabel.text = cellSettingsArray[indexPath.row]
        
        cell.categoryValueTitle.text = stepValues[indexPath.item]
        
        //here I add configuration
        //if let valueText = cell.categoryValueTitle.text {
            
            //iterate through for "DISTANCE" == km || money == $
            //let cellParameter = cellSettingsArray[indexPath.item].buttonTitle
            
            //configure last characters with function
            //cell.categoryValueTitle.attributedText = configureAttributedText(valueString: valueText, parameter: cellParameter)
//        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    
    
    //adding values to a project
    private func defineProjectsValues(){
        //clear old data
        stepValues.removeAll()
        
        //fill up new data ------------------------- data need to be rewised -----------------------------------
        ["\(step.cost)$", "\(step.distance)$", "\(step.cost)km"].forEach {
            stepValues.append($0)
        }
        //reload needed when browse btwn projects
        stepNumbersCollectionView.reloadData()
    }
    
    
    //configure part of the string to be smaller
    private func configureAttributedText(valueString: String, parameter: String) -> NSMutableAttributedString{
        // here I assign a specific style to a part of the string
        let smallFont = UIFont.systemFont(ofSize: 19)
        let attrString = NSMutableAttributedString(string: valueString)
        
        //because distance units is km, perform another configuration
        if parameter == "DISTANCE"{
            attrString.addAttribute(kCTFontAttributeName as NSAttributedString.Key, value: smallFont, range: NSMakeRange(valueString.count - 2 , 2))
        } else {
            attrString.addAttribute(kCTFontAttributeName as NSAttributedString.Key, value: smallFont, range: NSMakeRange(valueString.count - 1 , 1))
        }
        return attrString
    }
}

class StepNumbersCell: UICollectionViewCell {
    
    
    //initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let buttonTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(white: 0.40, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let categoryValueTitle: UILabel = {
        let label = UILabel()
        label.text = "1234567"
        label.textColor = UIColor.init(white: 0.40, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 26)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    func setupViews(){
        
        //mask content outside cell
        layer.masksToBounds = true
        layer.cornerRadius = 8
//        backgroundColor = .yellow
        
        
        
        addSubview(buttonTitleLabel)
        addSubview(categoryValueTitle)
        
        
        buttonTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryValueTitle.translatesAutoresizingMaskIntoConstraints = false
        
        categoryValueTitle.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        categoryValueTitle.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        categoryValueTitle.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        categoryValueTitle.heightAnchor.constraint(equalToConstant: 31).isActive = true
        
        buttonTitleLabel.topAnchor.constraint(equalTo: categoryValueTitle.bottomAnchor, constant: 0).isActive = true
        buttonTitleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        buttonTitleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        buttonTitleLabel.heightAnchor.constraint(equalToConstant: 17).isActive = true
    }

}
