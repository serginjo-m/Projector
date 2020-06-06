//
//  DetailViewCateg.swift
//  Projector
//
//  Created by Serginjo Melnik on 19.04.2020.
//  Copyright © 2020 Serginjo Melnik. All rights reserved.
//

import UIKit
import RealmSwift

class StepCategoriesCollectionView: UIStackView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{

    //Properties
    
    //Fetch Selected Project for Step CV modifications
    var project: ProjectList!
    
    
    var cellIdentificator = "cellID"
    
    //The List of Existing Step Categories in Project
    var existCategoryNames = ["All"]
    
    // as project id is defined, creates existing categories array
    var projectId = String() {
        didSet{
            updateCategoriesArray()
        }
    }
    
    //here we have a pointers for a change color purposes
    var categoryPointersArray = [UIView]()
    
    //parent collection view to reload after change
    var detailViewController: DetailViewController?

    //as selected category change, make modifications
    var selectedCategory = "All" {
        didSet{
            //modify database for stepsCollectionView
            modifyStepsArray()
        }
    }
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStepCategory()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupStepCategory()
    }
    
    //perform actions step by step
    func updateCategoriesCV(){
        //update existing step categories array
        updateCategoriesArray()
        //clear pointers from array, becouse CV adds new
        categoryPointersArray.removeAll()
        //reload step categories collection view
        stepCategoryCollectionView.reloadData()
        //set pointer to default position: "All"
        performButchUpdates()
    }
    
    //create array of existing categories in project
    func updateCategoriesArray (){
        // ----------------- maybe a little bit complicated ? -------------------------------
        //"All" is always first item in list of categories
        var array = ["All"]
        //convert selected project to sorted steps Dictionary for Detail Categoies Collection View
        let stepsDictionary = Dictionary(grouping: self.project.projectStep) { (step) -> String in
            return step.category
        }
        //get categories for array
        let keys = stepsDictionary.keys
        keys.forEach { (key) in
            array.append(key)
        }
        //define exist categories names
        existCategoryNames = array
    }
    //set pointer to default position: "All"
    func performButchUpdates(){
        stepCategoryCollectionView.performBatchUpdates({
            //reset all pointers color to white
            for item in categoryPointersArray{
                item.backgroundColor = .white
            }
            //than set first item ("All") as selected
        }) { (completed: Bool) in
            self.categoryPointersArray.first?.backgroundColor = UIColor(red: 1, green: 0.7, blue: 0.0, alpha: 1)
        }
    }
    
    //as selectedCategory change - func run
    func modifyStepsArray(){
        //clear array
        detailViewController!.stepsArray.removeAll()
        //full list in case "All" is selected
        if selectedCategory == "All"{
            //safe unwrap
            if let array = project?.projectStep{
                // ----------------- Is it clever, add one by one? -----------------
                for step in array {
                    detailViewController!.stepsArray.append(step)
                }
            }
        }else{
            //filter array by selectectedCategory property
            detailViewController!.stepsArray = project!.projectStep.filter({$0.category == selectedCategory})
        }
        
        detailViewController?.stepsCollectionView.reloadData()
    }
    
    //here creates a horizontal collectionView inside stackView
    let stepCategoryCollectionView: UICollectionView = {
        
        //instance for UICollectionView purposes
        let layout = UICollectionViewFlowLayout()
        
        //changing default direction of scrolling
        layout.scrollDirection = .horizontal
        
        //becouse every UICollectionView needs to have UICollectionViewFlowLayout, we need to create this inctance
        // & also we need to specify how "big" it needs to be
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        
        collectionView.backgroundColor = UIColor.clear
        
        //deactivate default constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()

    func setupStepCategory(){
        
        // Add a collectionView to the stackView
        addArrangedSubview(stepCategoryCollectionView)
        
        // ?? here we specify delegate & datasourse for generating our individual horizontal cells
        stepCategoryCollectionView.dataSource = self
        stepCategoryCollectionView.delegate = self
        
        //Class is need to be registered in order of using inside
        stepCategoryCollectionView.register(StepsCategoriesCell.self, forCellWithReuseIdentifier: cellIdentificator)
        
        //CollectionView constraints
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": stepCategoryCollectionView]))
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": stepCategoryCollectionView]))
    }
    
    //size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //this stuff is about finding a size of string
        let item = existCategoryNames[indexPath.row]
        var itemSize = item.size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)])
        //some sizes tweaks :)
        itemSize.height = 30
        itemSize.width = itemSize.width + 10
        
        return itemSize
        
    }
    
    //number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return existCategoryNames.count
    }
    
    //define the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentificator, for: indexPath) as! StepsCategoriesCell
        //set category name
        cell.categoryLabel.text = existCategoryNames[indexPath.row]
        //have to transfer this here becouse of dequeue problems
        cell.categoryLabel.frame = CGRect(x: 0, y: 0, width: Int(cell.frame.width), height: 30)
        cell.selectedCategoryPointer.frame = CGRect(x: 0, y: 26, width: Int(cell.frame.width), height: 8)
        //add pointers to array for changing color
        categoryPointersArray.append(cell.selectedCategoryPointer)
        //create CUSTOM tap gesture recognizer that have tag & title properties
        let labelTapGesture = MyGestureRecognizer(target: self, action: #selector(labelTapped))
        labelTapGesture.title = cell.categoryLabel.text!
        labelTapGesture.tag = indexPath.row
        labelTapGesture.numberOfTapsRequired = 1
        cell.categoryLabel.isUserInteractionEnabled = true
        cell.categoryLabel.addGestureRecognizer(labelTapGesture)
        return cell
    }
    //run as label tapped
    @objc func labelTapped(sender: MyGestureRecognizer){
        //set selected category title
        selectedCategory = sender.title
        //NOT A BETTER SOLUTION BECOUSE IT REALY SLOW DOWN APPLICATION?
        //iterate through array of pointers and set all of them to white
        for item in categoryPointersArray{
            item.backgroundColor = UIColor.white
        }
        //here I change color of selected pointer
        categoryPointersArray[sender.tag].backgroundColor = UIColor(red: 1, green: 0.7, blue: 0.0, alpha: 1)
    }
    
    
    
}

//uses for category labels
class MyGestureRecognizer: UITapGestureRecognizer{
    //will be selected category string
    var title = String()
    //define selected pointer in array
    var tag = Int()
}

class StepsCategoriesCell: UICollectionViewCell{
    
    //initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "NOTHING"
        label.textColor = UIColor.darkGray
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 15.0)
        return label
    }()
    
    let selectedCategoryPointer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 3
        return view
    }()
    
    func setupViews(){
        addSubview(categoryLabel)
        addSubview(selectedCategoryPointer)
    }
}
