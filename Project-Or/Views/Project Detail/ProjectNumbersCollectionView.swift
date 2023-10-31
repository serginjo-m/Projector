//
//  ProjectNumbersCollectionView.swift
//  Project-Or
//
//  Created by Serginjo Melnik on 30/10/23.
//  Copyright © 2023 Serginjo Melnik. All rights reserved.
//

import UIKit

class ProjectNumbersCollectionView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    private let cellID = "cellId"
    var projectValues = [String]()
    var project = ProjectList() {
        didSet{
            defineProjectsValues()
        }
    }
    
    let cellSettingsArray: [NumberCellSetting] = {
        return [
            NumberCellSetting(
                imageName: "totalCost",
                cellColor: UIColor.init(red: 95/255, green: 74/255, blue: 99/255, alpha: 1),
                buttonTitle: "MONEY SPENT",
                imageWidth: 55,
                imageHeight: 53,
                imageTopAnchor: 17,
                imageLeftAnchor: 0
            ),
            NumberCellSetting(
                imageName: "clock",
                cellColor:UIColor.init(red: 56/255, green: 136/255, blue: 255/255, alpha: 1),
                buttonTitle: "TIME SPENT",
                imageWidth: 110,
                imageHeight: 110,
                imageTopAnchor: -40,
                imageLeftAnchor: -45
            ),
            NumberCellSetting(
                imageName: "fuelC",
                cellColor: UIColor.init(red: 217/255, green: 98/255, blue: 72/255, alpha: 1),
                buttonTitle: "FUEL SPENT",
                imageWidth: 56,
                imageHeight: 63,
                imageTopAnchor: 7,
                imageLeftAnchor: 6
            )
        ]
    }()
    
    let didTapMoneyCompletionHandler: (() -> Void)
    let didTapTimeCompletionHandler: (() -> Void)
    let didTapFuelCompletionHandler: (() -> Void)
    
    //MARK: Initialization
    init(
        didTapMoneyCompletionHandler: @escaping (() -> Void),
        didTapTimeCompletionHandler: @escaping (() -> Void),
        didTapFuelCompletionHandler: @escaping (() -> Void)) {
        
        self.didTapMoneyCompletionHandler = didTapMoneyCompletionHandler
        self.didTapTimeCompletionHandler = didTapTimeCompletionHandler
        self.didTapFuelCompletionHandler = didTapFuelCompletionHandler
        
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    let projectNumbersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    func setupView(){
        addSubview(projectNumbersCollectionView)
        projectNumbersCollectionView.dataSource = self
        projectNumbersCollectionView.delegate = self
        projectNumbersCollectionView.showsHorizontalScrollIndicator = false
        projectNumbersCollectionView.showsVerticalScrollIndicator = false
        projectNumbersCollectionView.register(ProjectNumbersCell.self, forCellWithReuseIdentifier: cellID)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": projectNumbersCollectionView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": projectNumbersCollectionView]))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = projectValues[indexPath.row]
        var itemSize = item.size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30)])
        itemSize.height = 70.0
        itemSize.width += 40.0
        if itemSize.width < 125 {
            return CGSize(width: 125, height: itemSize.height)
        }
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ProjectNumbersCell
        cell.configureCell = cellSettingsArray[indexPath.row]
        cell.categoryValueTitle.text = projectValues[indexPath.item]
        if let valueText = cell.categoryValueTitle.text {
            let cellParameter = cellSettingsArray[indexPath.item].buttonTitle
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
            didTapMoneyCompletionHandler()
        case 1:
            didTapTimeCompletionHandler()
        case 2:
            didTapFuelCompletionHandler()
        default:
            break
        }
    }
    
    func defineProjectsValues(){
        
        guard let money = project.money, let time = project.time, let fuel = project.fuel else {
            print("project values error")
            return
        }
    
        projectValues.removeAll()
        
        ["\(money)$", "\(time)h", "\(fuel)l"].forEach {
            projectValues.append($0)
        }
        
        projectNumbersCollectionView.reloadData()
    }
    
    private func configureAttributedText(valueString: String, parameter: String) -> NSMutableAttributedString{
    
        let smallFont = UIFont.systemFont(ofSize: 19)
        let attrString = NSMutableAttributedString(string: valueString)
        
        if parameter == "DISTANCE"{
            attrString.addAttribute(kCTFontAttributeName as NSAttributedString.Key, value: smallFont, range: NSMakeRange(valueString.count - 2 , 2))
        } else {
            attrString.addAttribute(kCTFontAttributeName as NSAttributedString.Key, value: smallFont, range: NSMakeRange(valueString.count - 1 , 1))
        }
        return attrString
    }
}

