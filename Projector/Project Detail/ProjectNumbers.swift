//
//  RecentActivitiesCV.swift
//  Projector
//
//  Created by Serginjo Melnik on 31.10.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

// template that holds configuration for every cell
class NumberCellSetting: NSObject{
    let imageName: String
    let cellColor: UIColor
    let buttonTitle: String
    let imageWidth: CGFloat
    let imageHeight: CGFloat
    let imageTopAnchor: CGFloat
    let imageLeftAnchor: CGFloat
    
    init(imageName: String, cellColor: UIColor, buttonTitle: String, imageWidth: CGFloat, imageHeight: CGFloat, imageTopAnchor: CGFloat, imageLeftAnchor: CGFloat){
        self.imageName = imageName
        self.cellColor = cellColor
        self.buttonTitle = buttonTitle
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.imageTopAnchor = imageTopAnchor
        self.imageLeftAnchor = imageLeftAnchor
    }
}

class ProjectNumbersCollectionView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    
    //this property need for cells
    private let cellID = "cellId"
    
    var projectValues = [String]()
    
    //Database
    var project = ProjectList() {
        didSet{
            //define values of a project
            defineProjectsValues()
        }
    }
    
    // cell settings
    let cellSettingsArray: [NumberCellSetting] = {
        return [
            NumberCellSetting(
                imageName: "totalCost",
                cellColor: UIColor.init(red: 95/255, green: 74/255, blue: 99/255, alpha: 1),
                buttonTitle: "TOTAL COST",
                imageWidth: 55,
                imageHeight: 53,
                imageTopAnchor: 17,
                imageLeftAnchor: 0
            ),
            NumberCellSetting(
                imageName: "budget",
                cellColor:UIColor.init(red: 56/255, green: 136/255, blue: 255/255, alpha: 1),
                buttonTitle: "BUDGET",
                imageWidth: 68,
                imageHeight: 81,
                imageTopAnchor: 3,
                imageLeftAnchor: -18
            ),
            NumberCellSetting(
                imageName: "distance",
                cellColor: UIColor.init(red: 132/255, green: 211/255, blue: 171/255, alpha: 1),
                buttonTitle: "DISTANCE",
                imageWidth: 76,
                imageHeight: 82,
                imageTopAnchor: 8,
                imageLeftAnchor: -11
            )
        ]
    }()
    
    let didTapBudgetCompletionHandler: (() -> Void)
    let didTapTotalCostCompletionHandler: (() -> Void)
    let didTapDistanceCompletionHandler: (() -> Void)
    //MARK: Initialization
    
    init(
        didTapBudgetCompletionHandler: @escaping (() -> Void),
        didTapTotalCostCompletionHandler: @escaping (() -> Void),
        didTapDistanceCompletionHandler: @escaping (() -> Void)) {
        
        self.didTapBudgetCompletionHandler = didTapBudgetCompletionHandler
        self.didTapTotalCostCompletionHandler = didTapTotalCostCompletionHandler
        self.didTapDistanceCompletionHandler = didTapDistanceCompletionHandler
        
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    //here creates a horizontal collectionView inside stackView
    let projectNumbersCollectionView: UICollectionView = {
        
        //instance for UICollectionView purposes
        let layout = UICollectionViewFlowLayout()
        
        //changing default direction of scrolling
        layout.scrollDirection = .horizontal
        
        //spacing...
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //layout.itemSize = CGSize(width: 120, height: 45)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        
        //becouse every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        
        collectionView.backgroundColor = UIColor.clear
        
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    func setupView(){
        
        // Add a collectionView to the stackView
        
        addSubview(projectNumbersCollectionView)
        
        // ?? here we specify delegate & datasourse for generating our individual horizontal cells
        projectNumbersCollectionView.dataSource = self
        projectNumbersCollectionView.delegate = self
        
        projectNumbersCollectionView.showsHorizontalScrollIndicator = false
        projectNumbersCollectionView.showsVerticalScrollIndicator = false
        
        //Class is need to be registered in order of using inside
        projectNumbersCollectionView.register(ProjectNumbersCell.self, forCellWithReuseIdentifier: cellID)
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": projectNumbersCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": projectNumbersCollectionView]))
    }
    
    //size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        

        //projects value string
        let item = projectValues[indexPath.row]
        
        //cell size will be dynamically calculated based on string size
        var itemSize = item.size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30)])
        
        
        //increase height for description label
        itemSize.height = 70.0
        itemSize.width += 40.0
        
        //becouse if size too small description will be covered
        if itemSize.width < 125 {
            return CGSize(width: 125, height: itemSize.height)
        }
        
        return itemSize
        
    }
    //number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    //define the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ProjectNumbersCell
        
        //here is IMPORTANT part, when I pass settings for every cell
        cell.configureCell = cellSettingsArray[indexPath.row]
        
        cell.categoryValueTitle.text = projectValues[indexPath.item]
        
        //here I add configuration
        if let valueText = cell.categoryValueTitle.text {
            
            //iterate through for "DISTANCE" == km || money == $
            let cellParameter = cellSettingsArray[indexPath.item].buttonTitle
            
            //configure last characters with function
            cell.categoryValueTitle.attributedText = configureAttributedText(valueString: valueText, parameter: cellParameter)
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.row{
        case 0:
            //total cost
            didTapTotalCostCompletionHandler()
        case 1:
            //budget
            didTapBudgetCompletionHandler()
        case 2:
            //distance
            didTapDistanceCompletionHandler()
        default:
            break
            
        }
    }
    
    
    
    //adding values to a project
    private func defineProjectsValues(){
        //clear old data
        projectValues.removeAll()
        
        //fill up new data
        ["\(project.money)$", "\(project.time)hrs", "\(project.fuel)l"].forEach {
            projectValues.append($0)
        }
        //reload needed when browse btwn projects
        projectNumbersCollectionView.reloadData()
    }
    
    
    //configure part of the string to be smaller
    private func configureAttributedText(valueString: String, parameter: String) -> NSMutableAttributedString{
        // here I assign a specific style to a part of the string
        let smallFont = UIFont.systemFont(ofSize: 19)
        let attrString = NSMutableAttributedString(string: valueString)
        
        //becouse distance units is km, perform another configuration
        if parameter == "DISTANCE"{
            attrString.addAttribute(kCTFontAttributeName as NSAttributedString.Key, value: smallFont, range: NSMakeRange(valueString.count - 2 , 2))
        } else {
            attrString.addAttribute(kCTFontAttributeName as NSAttributedString.Key, value: smallFont, range: NSMakeRange(valueString.count - 1 , 1))
        }
        return attrString
    }
}

class ProjectNumbersCell: UICollectionViewCell {
    //cell configuration object
    var configureCell: NumberCellSetting? {
        didSet{
            if let setting = configureCell{
                
                //constraints func , becouse elements needs to be positioned differently
                configureConstraints(width: setting.imageWidth, height: setting.imageHeight, top: setting.imageTopAnchor, left: setting.imageLeftAnchor)
                
                //background color
                backgroundColor = setting.cellColor
                
                //title
                buttonTitleLabel.text = setting.buttonTitle
                
                //image
                buttonBackgroundImage.image = UIImage(named: setting.imageName)
            }
        }
    }
    
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
        label.textColor = UIColor.init(white: 1, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let buttonBackgroundImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "notes")
        return image
    }()
    
    let categoryValueTitle: UILabel = {
        let label = UILabel()
        label.text = "1234567"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    func setupViews(){
        
        //mask content outside cell
        layer.masksToBounds = true
        layer.cornerRadius = 8
        
        addSubview(buttonBackgroundImage)
        addSubview(buttonTitleLabel)
        addSubview(categoryValueTitle)
        
        
        buttonTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryValueTitle.translatesAutoresizingMaskIntoConstraints = false
        
        buttonTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).isActive = true
        buttonTitleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        buttonTitleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        buttonTitleLabel.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        categoryValueTitle.bottomAnchor.constraint(equalTo: buttonTitleLabel.topAnchor, constant: 15).isActive = true
        categoryValueTitle.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        categoryValueTitle.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        categoryValueTitle.heightAnchor.constraint(equalToConstant: 43).isActive = true
    }
    
    //Don't know why but, it is better to use frame not constraint when dequeue issue occurs
    func configureConstraints(width: CGFloat, height: CGFloat, top: CGFloat, left: CGFloat){
        buttonBackgroundImage.frame = CGRect(x: left, y: top, width: width, height: height)
    }
}
